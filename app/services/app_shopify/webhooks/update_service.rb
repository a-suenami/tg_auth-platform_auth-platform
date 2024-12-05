# typed: false

module AppShopify::Webhooks
  class UpdateService < BaseService
    def sync_customer
      event_catcher
    end

    def valid_event?
      if @event[:'detail-type'] != 'shopifyWebhook'
        raise Exceptions::Shopify::WebhookEventInvaildError, "rejected for invalid detail-type #{@event[:'detail-type']}"
      end
      if @event.dig(:detail, :payload).nil?
        raise Exceptions::Shopify::WebhookEventInvaildError
      end
      if @event.dig(:detail, :payload, :email).nil?
        raise Exceptions::Shopify::WebhookEventInvaildError
      end
      if @event.dig(:detail, :payload, :multipass_identifier).nil?
        # multipass_identifierがない => shopify管理画面で作成されたユーザの可能性が高い
        # 同期処理はスキップ
        return false
      end

      # HTTP webhook以外では、 event['detail']['metadata']['X-Shopify-Hmac-SHA256'] のベリファイは不要
      # (公式ドキュメントによる)
      true
    end

    def event_catcher
      return unless valid_event?

      case @event[:detail][:metadata][:'X-Shopify-Topic']
      when 'customers/create', 'customers/update'
        upsert_customer
      end
    end

    def upsert_customer
      user = User.find_by(id: @event.dig(:detail, :payload, :multipass_identifier))
      # 対応するUserが存在しない場合はスキップ
      return if user.nil?

      shopify_customer = user.shopify_customers.find_by(multipass_store: @multipass_store)

      if shopify_customer.present?
        shopify_customer.update(
          remote_id: @event.dig(:detail, :payload, :id),
          email: @event.dig(:detail, :payload, :email),
          updated_at: @event.dig(:detail, :payload, :updated_at),
          tags: @event.dig(:detail, :payload, :tags),
        )
      else
        user.shopify_customers.create(
          multipass_store: @multipass_store,
          store_name: @multipass_store.store_name,
          remote_id: @event.dig(:detail, :payload, :id),
          email: @event.dig(:detail, :payload, :email),
          updated_at: @event.dig(:detail, :payload, :updated_at),
          tags: @event.dig(:detail, :payload, :tags),
        )
      end
    end
  end
end
