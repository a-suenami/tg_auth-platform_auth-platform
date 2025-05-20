# typed: false
# frozen_string_literal: true

require 'uri'

# SafeUrlParser provides methods to safely parse URLs that may contain
# non-ASCII characters (like Japanese) in various states of encoding.
module SafeUrlParser
  class << self
    # Parses a URL string into a URI object, handling various encoding patterns
    # @param url [String] The URL to parse
    # @return [URI::Generic] A parsed URI object
    # @raise [URI::InvalidURIError] If the URL is fundamentally invalid
    def parse(url)
      return nil if url.blank?

      # 1. https://が%エンコードされている場合はデコード
      decoded_url = decode_encoded_scheme(url)
      # 2. 非ASCII文字が含まれている場合は%エンコード
      encoded_url = encode_non_ascii(decoded_url)
      # 3. パースして返す
      URI.parse(encoded_url)
    end

    private

    # %エンコードされたhttps://をデコードする
    # @param url [String] デコードするURL
    # @return [String] デコードされたURL
    def decode_encoded_scheme(url)
      return url unless url.include?('%')

      if url.match?(/https?%3A%2F%2F/)
        URI::DEFAULT_PARSER.unescape(url)
      else
        url
      end
    end

    # 非ASCII文字をエンコードする
    # @param url [String] エンコードするURL
    # @return [String] エンコードされたURL
    def encode_non_ascii(url)
      return url if url.ascii_only?

      URI::DEFAULT_PARSER.escape(url)
    end
  end
end
