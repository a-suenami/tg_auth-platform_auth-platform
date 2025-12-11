# typed: strict

module Blastengine
  class API
    extend T::Sig

    RETRY_OPTIONS = T.let({
      max: 3,
      interval: 0.05,
      interval_randomness: 0.5,
      backoff_factor: 2,
      exceptions: Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed],
    }.freeze, T::Hash[T.untyped, T.untyped],)

    sig { returns(T.untyped) }
    attr_accessor :client

    sig { void }
    def initialize
      @endpoint_url = T.let('https://app.engn.jp', String)
      @client = T.let(Faraday.new(@endpoint_url) do |f|
        f.request :retry, RETRY_OPTIONS
        f.response :json
        f.headers = {
          Authorization: "Bearer #{access_token}",
          'Content-Type': 'application/json',
          'Accept-Language': 'ja-JP',
        }
      end, T.untyped,)
    end

    # Send single email via Transaction API
    sig { params(send_to: String, subject: String, body: String, from_email: T.nilable(String), from_name: T.nilable(String)).returns(T.untyped) }
    def send_email(send_to:, subject:, body:, from_email:, from_name:)
      if !Rails.env.production? && Settings.super_mode == true # SUPER_MODE では送らない
        sleep(rand(0.05..0.1))
        return
      end

      from_email = 'idp@id-platform.net' if from_email.blank?
      from_name = 'ID Platform' if from_name.blank?

      request(:post, '/api/v1/deliveries/transaction', {
        from: { email: from_email, name: from_name },
        to: send_to,
        subject:,
        text_part: ActionView::Base.full_sanitizer.sanitize(body, tags: []),
        html_part: body,
      },)
    end

    # ============================================================
    # Bulk Delivery API
    # ============================================================

    # Step 1: Create bulk delivery (EDIT status)
    sig { params(subject: String, text_part: String, html_part: String, from_email: String, from_name: String).returns(T.untyped) }
    def bulk_begin(subject:, text_part:, html_part:, from_email:, from_name:)
      request(:post, '/api/v1/deliveries/bulk/begin', {
        from: { email: from_email, name: from_name },
        subject: subject,
        text_part: text_part,
        html_part: html_part,
      },)
    end

    # Step 2: Upload CSV with recipients
    sig { params(delivery_id: Integer, csv_content: String).returns(T.untyped) }
    def bulk_import_csv(delivery_id:, csv_content:)
      # Need multipart client for file upload
      multipart_client = Faraday.new(@endpoint_url) do |f|
        f.request :multipart
        f.request :retry, RETRY_OPTIONS
        f.response :json
        f.headers = {
          'Authorization' => "Bearer #{access_token}",
          'Accept-Language' => 'ja-JP',
        }
      end

      payload = {
        file: Faraday::Multipart::FilePart.new(
          StringIO.new(csv_content),
          'text/csv',
          'emails.csv',
        ),
      }

      response = multipart_client.post("/api/v1/deliveries/#{delivery_id}/emails/import", payload)

      if response.status.to_s !~ /2\d\d/
        raise Exceptions::API::ServerError.new(body: response.body, status: response.status)
      end

      response.body
    end

    # Check CSV import status
    # Note: endpoint uses "-" instead of delivery_id per Blastengine docs
    sig { params(job_id: String).returns(T.untyped) }
    def bulk_import_status(job_id:)
      request(:get, "/api/v1/deliveries/-/emails/import/#{job_id}")
    end

    # Step 3: Commit with reservation time (schedule)
    sig { params(delivery_id: Integer, reservation_time: String).returns(T.untyped) }
    def bulk_commit(delivery_id:, reservation_time:)
      request(:patch, "/api/v1/deliveries/bulk/commit/#{delivery_id}", {
        reservation_time: reservation_time,
      },)
    end

    # Cancel scheduled bulk delivery
    sig { params(delivery_id: Integer).returns(T.untyped) }
    def bulk_cancel(delivery_id:)
      request(:patch, "/api/v1/deliveries/bulk/commit/#{delivery_id}/cancel")
    end

    # Get delivery logs/results (per-recipient)
    sig { params(delivery_id: Integer, size: Integer, page: Integer).returns(T.untyped) }
    def delivery_logs(delivery_id:, size: 100, page: 1)
      request(:get, '/api/v1/logs/mails/results', {
        delivery_id: delivery_id,
        size: size,
        page: page,
      },)
    end

    # Get delivery detail (aggregated results)
    # https://blastengine.jp/documents/#tag/deliveries/operation/delivery-detail-get
    # Response: { open_count, total_count, sent_count, drop_count, soft_error_count, hard_error_count, ... }
    sig { params(delivery_id: Integer).returns(T.untyped) }
    def delivery_detail(delivery_id:)
      request(:get, "/api/v1/deliveries/#{delivery_id}")
    end

    private

    sig { returns(String) }
    def access_token
      hashed_token = Digest::SHA256.hexdigest(Settings.blastengine.user_id + Settings.blastengine.api_key)
      Base64.encode64(hashed_token.downcase).gsub("\n", '')
    end

    sig { params(http_method: Symbol, path: String, params: T.untyped, headers: T.untyped).returns(T.untyped) }
    def request(http_method, path, params = nil, headers = {})
      raise unless http_method.to_sym.in? [:get, :post, :put, :patch, :delete]

      response = case http_method
      when :get, :delete
        @client.send(http_method, path, params, headers)
      when :post, :put, :patch
        @client.send(http_method, path, params&.to_json, headers)
      end

      body = response.body

      if response.status.to_s !~ /2\d\d/
        raise Exceptions::API::ServerError.new(body:, status: response.status)
      end

      body
    end
  end
end
