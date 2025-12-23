# typed: strict
# frozen_string_literal: true

module S3
  class Uploader
    extend T::Sig

    sig { returns(Aws::S3::Client) }
    attr_reader :client

    sig { void }
    def initialize
      # ローカル開発環境（minio）の場合はENV変数を直接使用
      if ENV['AWS_S3_ENDPOINT'].present?
        client_options = {
          access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
          secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
          region: ENV.fetch('AWS_REGION', 'ap-northeast-1'),
          endpoint: ENV['AWS_S3_ENDPOINT'],
          force_path_style: true
        }
      else
        client_options = {
          access_key_id: Settings.aws.access_key_id,
          secret_access_key: Settings.aws.secret_access_key,
          region: Settings.aws.region
        }
      end

      @client = T.let(Aws::S3::Client.new(client_options), Aws::S3::Client)
    end

    # ファイルをS3にアップロードし、公開URLを返す
    sig { params(file: ActionDispatch::Http::UploadedFile, path: String, content_type: T.nilable(String)).returns(String) }
    def upload(file:, path:, content_type: nil)
      content_type ||= file.content_type || 'application/octet-stream'

      @client.put_object(
        bucket: bucket,
        key: path,
        body: file.read,
        content_type: content_type,
        acl: 'public-read'
      )

      public_url(path)
    end

    # S3からファイルを削除
    sig { params(path: String).void }
    def delete(path:)
      @client.delete_object(
        bucket: bucket,
        key: path
      )
    rescue Aws::S3::Errors::NoSuchKey
      # ファイルが存在しない場合は無視
    end

    # URLからS3のpathを抽出
    sig { params(url: String).returns(T.nilable(String)) }
    def extract_path_from_url(url)
      return nil if url.blank?

      base = cloudfront_host
      return nil unless url.start_with?(base)

      url.sub(base, '').sub(%r{^/}, '')
    end

    private

    sig { returns(String) }
    def bucket
      Settings.aws.s3.media_bucket
    end

    sig { returns(String) }
    def cloudfront_host
      Settings.aws.s3.cloudfront_media_host
    end

    sig { params(path: String).returns(String) }
    def public_url(path)
      "#{cloudfront_host}/#{path}"
    end
  end
end
