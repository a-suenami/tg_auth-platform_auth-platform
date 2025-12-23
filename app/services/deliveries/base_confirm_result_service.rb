# typed: strict

module Deliveries
  # Base class for syncing delivery results from Blastengine
  # Template method pattern - subclasses implement abstract methods
  #
  # Shared logic:
  # - API pagination loop
  # - Recipient status updates (SENT, DROP, etc.)
  # - Sync delivery result aggregates
  #
  # Subclass responsibilities:
  # - blastengine_delivery_id: which model holds the ID
  # - delivery_target: which model to update (schedule/birthday)
  # - can_sync?: status check before syncing
  # - find_recipient: how to find recipient (with/without delivery_date)
  # - on_completion: what to do when all recipients processed
  class BaseConfirmResultService
    extend T::Sig
    extend T::Helpers

    abstract!

    sig { params(delivery: Delivery).void }
    def initialize(delivery:)
      @delivery = delivery
      @api = T.let(Blastengine::API.new, Blastengine::API)
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def execute
      return { success: false, error: 'Not applicable' } unless can_sync?
      return { success: false, error: 'No Blastengine ID' } if blastengine_delivery_id.blank?

      sync_delivery_result
      total_synced = sync_logs_paginated

      check_completion

      { success: true, synced: total_synced }
    rescue StandardError => e
      error_detail = build_error_detail(e)
      Rails.logger.error("[#{self.class.name}] Failed: #{error_detail}")
      { success: false, error: error_detail }
    end

    private

    sig { params(error: StandardError).returns(String) }
    def build_error_detail(error)
      return error.message unless error.respond_to?(:body)

      body = T.unsafe(error).body
      return error.message if body.blank?

      "#{error.message} | API: #{body}"
    end

    # --- Abstract methods (must be implemented by subclasses) ---

    sig { abstract.returns(T.nilable(T.any(Integer, String))) }
    def blastengine_delivery_id; end

    sig { abstract.returns(T::Boolean) }
    def can_sync?; end

    sig { abstract.params(log: T::Hash[String, T.untyped]).returns(T.nilable(DeliveryRecipient)) }
    def find_recipient(log); end

    sig { abstract.void }
    def on_completion; end

    sig { abstract.returns(T::Hash[Symbol, T.untyped]) }
    def delivery_result_attributes; end

    sig { abstract.returns(T::Boolean) }
    def pending_recipients?; end

    # --- Shared implementation ---

    sig { void }
    def sync_delivery_result
      detail = @api.delivery_detail(delivery_id: blastengine_delivery_id.to_i)

      delivery_result = DeliveryResult.find_or_initialize_by(
        blastengine_delivery_id: blastengine_delivery_id,
      )

      delivery_result.assign_attributes(
        tenant_id: @delivery.tenant_id,
        delivery_id: @delivery.id,
        total_count: detail['total_count'] || 0,
        sent_count: detail['sent_count'] || 0,
        drop_count: detail['drop_count'] || 0,
        soft_error_count: detail['soft_error_count'] || 0,
        hard_error_count: detail['hard_error_count'] || 0,
        open_count: detail['open_count'] || 0,
        synced_at: Time.current,
        **delivery_result_attributes,
      )
      delivery_result.save!

      Rails.logger.info("[#{self.class.name}] Synced: sent=#{detail['sent_count']}/#{detail['total_count']}")
    end

    sig { returns(Integer) }
    def sync_logs_paginated
      page = 1
      total_synced = 0

      loop do
        result = @api.delivery_logs(
          delivery_id: blastengine_delivery_id.to_i,
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

      total_synced
    end

    sig { params(logs: T::Array[T::Hash[String, T.untyped]]).void }
    def sync_logs(logs)
      logs.each do |log|
        recipient = find_recipient(log)
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
      return if pending_recipients?

      on_completion
      Rails.logger.info("[#{self.class.name}] Delivery #{@delivery.id} completed")
    end
  end
end
