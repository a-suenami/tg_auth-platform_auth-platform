# typed: strict

module AppShopify::Webhooks
  class UpdateService < BaseService
    sig { void }
    def sync_customer
      event_catcher
    end

    sig { returns(T::Boolean) }
    def valid_event?
      if @event[:'detail-type'] != 'shopifyWebhook'
        raise Exceptions::Shopify::WebhookEventInvaildError, "rejected for invalid detail-type #{@event[:'detail-type']}"
      end
      if @event.dig(:detail, :payload).nil?
        raise Exceptions::Shopify::WebhookEventInvaildError
      end

      if @event[:detail][:metadata][:'X-Shopify-Topic'].in?(['customers/create', 'customers/update'])
        if @event.dig(:detail, :payload, :email).nil?
          raise Exceptions::Shopify::WebhookEventInvaildError
        end
        if @event.dig(:detail, :payload, :multipass_identifier).nil?
          # multipass_identifierがない => shopify管理画面で作成されたユーザの可能性が高い
          # 同期処理はスキップ
          return false
        end
      end

      # HTTP webhook以外では、 event['detail']['metadata']['X-Shopify-Hmac-SHA256'] のベリファイは不要
      # (公式ドキュメントによる)
      true
    end

    sig { void }
    def event_catcher
      return unless valid_event?

      case @event[:detail][:metadata][:'X-Shopify-Topic']
      when 'customers/create', 'customers/update'
        upsert_customer
      when 'customer_tags_added'
        handle_customer_tags_added
      when 'customer_tags_removed'
        handle_customer_tags_removed
      end
    end

    sig { void }
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
          # tagsフィールドは2025-01以降のAPIバージョンでは削除されているため、別途CUSTOMER_TAGS_ADDED/REMOVEDで処理
        )
      else
        user.shopify_customers.create(
          multipass_store: @multipass_store,
          store_name: @multipass_store.store_name,
          remote_id: @event.dig(:detail, :payload, :id),
          email: @event.dig(:detail, :payload, :email),
          updated_at: @event.dig(:detail, :payload, :updated_at),
          # tagsフィールドは2025-01以降のAPIバージョンでは削除されているため、別途CUSTOMER_TAGS_ADDED/REMOVEDで処理
        )
      end
    end

    sig { void }
    def handle_customer_tags_added
      customer_id = @event.dig(:detail, :payload, :customerId)
      added_tags = @event.dig(:detail, :payload, :tags_added) || []

      if customer_id.blank?
        return
      end

      customer_id = customer_id.split('/').last

      shopify_customer = ShopifyRecord::Customer.find_by(
        multipass_store: @multipass_store,
        remote_id: customer_id,
      )

      return if shopify_customer.nil?

      current_tags = shopify_customer.tags.to_s.split(',').map(&:strip).compact_blank
      new_tags = (current_tags + added_tags).uniq

      shopify_customer.update(tags: new_tags.join(','))
    end

    sig { void }
    def handle_customer_tags_removed
      customer_id = @event.dig(:detail, :payload, :customerId)
      removed_tags = @event.dig(:detail, :payload, :tags_removed) || []

      if customer_id.blank?
        return
      end

      customer_id = customer_id.split('/').last

      shopify_customer = ShopifyRecord::Customer.find_by(
        multipass_store: @multipass_store,
        remote_id: customer_id,
      )

      return if shopify_customer.nil?

      current_tags = shopify_customer.tags.to_s.split(',').map(&:strip).compact_blank
      new_tags = current_tags - removed_tags

      shopify_customer.update(tags: new_tags.join(','))
    end
  end
end
