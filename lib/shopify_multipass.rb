# typed: false

require 'openssl'
require 'base64'
require 'time'
require 'json'

# https://shopify.dev/api/multipass#example-implementation
class ShopifyMultipass
  def initialize(multipass_secret)
    ### Use the Multipass secret to derive two cryptographic keys,
    ### one for encryption, one for signing
    key_material = OpenSSL::Digest.new('sha256').digest(multipass_secret)
    @encryption_key = key_material[0, 16]
    @signature_key  = key_material[16, 16]
  end

  def generate_token(customer_data_hash)
    ### Store the current time in ISO8601 format.
    ### The token will only be valid for a small timeframe around this timestamp.
    customer_data_hash['created_at'] = Time.now.iso8601

    ### Serialize the customer data to JSON and encrypt it
    ciphertext = encrypt(customer_data_hash.to_json)

    ### Create a signature (message authentication code) of the ciphertext
    ### and encode everything using URL-safe Base64 (RFC 4648)
    Base64.urlsafe_encode64(ciphertext + sign(ciphertext))
  end

  private

  def encrypt(plaintext)
    cipher = OpenSSL::Cipher.new('aes-128-cbc')
    cipher.encrypt
    cipher.key = @encryption_key

    ### Use a random IV
    cipher.iv = iv = cipher.random_iv

    ### Use IV as first block of ciphertext
    iv + cipher.update(plaintext) + cipher.final
  end

  def sign(data)
    OpenSSL::HMAC.digest('sha256', @signature_key, data)
  end
end
