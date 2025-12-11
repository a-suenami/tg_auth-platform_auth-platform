# typed: strict

module Deliveries
  # ConfirmResultService syncs delivery results from Blastengine
  # Updates DeliveryRecipient statuses and DeliveryResult aggregates
  class ConfirmResultService
    extend T::Sig

    sig { params(schedule: DeliverySchedule).void }
    def initialize(schedule:)
      @schedule = schedule
      @delivery = T.let(T.must(schedule.delivery), Delivery)
      @api = T.let(Blastengine::API.new, Blastengine::API)
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def execute
      # Allow sync for both 'delivering' and 'delivered' (to update open rates)
      return { success: false, error: 'Not applicable' } unless %w[delivering delivered].include?(@schedule.status)
      return { success: false, error: 'No Blastengine ID' } if @schedule.blastengine_delivery_id.blank?

      # Sync aggregated results first
      sync_delivery_result

      # Sync per-recipient logs
      page = 1
      total_synced = 0

      loop do
        result = @api.delivery_logs(
          delivery_id: @schedule.blastengine_delivery_id.to_i,
          size: 100,
          page: page,
        )

        logs = result['data'] || []
        break if logs.empty?

        sync_logs(logs)
        total_synced += logs.size

        break if logs.size < 100

        page += 1
      end

      check_completion

      { success: true, synced: total_synced }
    rescue StandardError => e
      Rails.logger.error("[ConfirmResultService] Failed: #{e.message}")
      { success: false, error: e.message }
    end

    private

    sig { void }
    def sync_delivery_result
      detail = @api.delivery_detail(delivery_id: @schedule.blastengine_delivery_id.to_i)

      delivery_result = DeliveryResult.find_or_initialize_by(
        blastengine_delivery_id: @schedule.blastengine_delivery_id,
      )
      delivery_result.assign_attributes(
        tenant_id: @delivery.tenant_id,
        delivery_id: @delivery.id,
        delivery_schedule_id: @schedule.id,
        total_count: detail['total_count'] || 0,
        sent_count: detail['sent_count'] || 0,
        drop_count: detail['drop_count'] || 0,
        soft_error_count: detail['soft_error_count'] || 0,
        hard_error_count: detail['hard_error_count'] || 0,
        open_count: detail['open_count'] || 0,
        synced_at: Time.current,
      )
      delivery_result.save!

      Rails.logger.info("[ConfirmResultService] Synced delivery result: sent=#{detail['sent_count']}/#{detail['total_count']}")
    end

    sig { params(logs: T::Array[T::Hash[String, T.untyped]]).void }
    def sync_logs(logs)
      logs.each do |log|
        recipient = DeliveryRecipient.joins(:user)
                                     .find_by(delivery_id: @delivery.id, users: { email: log['email'] })
        next unless recipient
        next if recipient.sent? || recipient.failed? # Already processed

        case log['status']
        when 'SENT'
          recipient.update!(status: 'sent', sent_at: Time.zone.parse(log['delivery_time']))
        when 'DROP', 'HARDBOUNCE', 'SOFTBOUNCE'
          recipient.update!(status: 'failed', error_message: log['status'])
        end
      end
    end

    sig { void }
    def check_completion
      pending = DeliveryRecipient.exists?(delivery_id: @delivery.id, status: 'pending')

      unless pending
        @schedule.update!(status: 'delivered')
        DeliveryEvent.record!(
          delivery: @delivery,
          event: DeliveryEvent::Type::Sent.new(payload: { source: 'bulk_sync' }),
          admin: nil,
        )
        Rails.logger.info("[ConfirmResultService] Delivery #{@delivery.id} completed")
      end
    end
  end
end
