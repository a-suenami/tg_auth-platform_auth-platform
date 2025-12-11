# typed: strict

module Deliveries
  module Birthday
    # ConfirmResultService syncs daily birthday delivery results from Blastengine
    # Updates DeliveryRecipient statuses and resets birthday status for next day
    class ConfirmResultService
      extend T::Sig

      sig { params(birthday: DeliveryBirthday).void }
      def initialize(birthday:)
        @birthday = birthday
        @delivery = T.let(T.must(birthday.delivery), Delivery)
        @api = T.let(Blastengine::API.new, Blastengine::API)
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def execute
        return { success: false, error: 'Not delivering' } unless @birthday.status == 'delivering'
        return { success: false, error: 'No Blastengine ID' } if @birthday.blastengine_delivery_id.blank?

        # Sync aggregated results
        sync_delivery_result

        # Sync per-recipient logs
        page = 1
        total_synced = 0

        loop do
          result = @api.delivery_logs(
            delivery_id: @birthday.blastengine_delivery_id.to_i,
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
        Rails.logger.error("[Birthday::ConfirmResultService] Failed: #{e.message}")
        { success: false, error: e.message }
      end

      private

      sig { void }
      def sync_delivery_result
        detail = @api.delivery_detail(delivery_id: @birthday.blastengine_delivery_id.to_i)

        delivery_result = DeliveryResult.find_or_initialize_by(
          blastengine_delivery_id: @birthday.blastengine_delivery_id,
        )
        delivery_result.assign_attributes(
          tenant_id: @delivery.tenant_id,
          delivery_id: @delivery.id,
          delivery_birthday_id: @birthday.id,
          delivery_date: @birthday.last_setup_date,
          total_count: detail['total_count'] || 0,
          sent_count: detail['sent_count'] || 0,
          drop_count: detail['drop_count'] || 0,
          soft_error_count: detail['soft_error_count'] || 0,
          hard_error_count: detail['hard_error_count'] || 0,
          open_count: detail['open_count'] || 0,
          synced_at: Time.current,
        )
        delivery_result.save!

        Rails.logger.info("[Birthday::ConfirmResultService] Synced: sent=#{detail['sent_count']}/#{detail['total_count']}")
      end

      sig { params(logs: T::Array[T::Hash[String, T.untyped]]).void }
      def sync_logs(logs)
        # Only sync recipients for the current delivery date
        delivery_date = @birthday.last_setup_date
        logs.each do |log|
          recipient = DeliveryRecipient.joins(:user)
                                       .find_by(
                                         delivery_id: @delivery.id,
                                         delivery_date: delivery_date,
                                         users: { email: log['email'] },
                                       )
          next unless recipient
          next if recipient.sent? || recipient.failed?

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
        # Check if all today's recipients are processed (scoped by delivery_date)
        delivery_date = @birthday.last_setup_date
        today_pending = DeliveryRecipient.exists?(
          delivery_id: @delivery.id,
          delivery_date: delivery_date,
          status: 'pending',
        )

        unless today_pending
          # Reset to ongoing for next day (birthday is recurring)
          @birthday.update!(status: 'ongoing')
          Rails.logger.info('[Birthday::ConfirmResultService] Day complete, reset to ongoing')
        end
      end
    end
  end
end
