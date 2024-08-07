# typed: true

# ==============================================================================
# app/lib/app_encryptor.rb
# ==============================================================================
module AppEncryptor
  extend T::Sig

  SECRET = Rails.application.secret_key_base.freeze
  ITERATIONS = 1000
  CIPHER = 'aes-256-gcm'.freeze
  private_constant :SECRET
  private_constant :ITERATIONS
  private_constant :CIPHER


  class Current < T::Struct
    prop :secret,     String, sensitivity: []
    prop :iterations, Integer
    prop :cipher,     String
  end

  class Previous < T::Struct
    prop :secret,     T.nilable(String), sensitivity: []
    prop :iterations, T.nilable(Integer)
    prop :cipher,     T.nilable(String)
  end

  CURRENT = Current.new(Settings.encryptor.current.to_h)
  PREVIOUS = Previous.new(Settings.encryptor.previous.to_h)

  class << self
    extend T::Sig

    sig { params(message: String, salt: String).returns(String) }
    def encrypt(message, salt:)
      self.build_encryptor(salt).encrypt_and_sign(message)
    end

    sig { params(cipher_text: String, salt: String).returns(String) }
    def decrypt(cipher_text, salt:)
      self.build_encryptor(salt).decrypt_and_verify(cipher_text)
    end

    def build_encryptor(salt)
      current_secret = self.generate_secret(CURRENT.secret, CURRENT.iterations, CURRENT.cipher, salt:)
      encryptor = ActiveSupport::MessageEncryptor.new(current_secret, cipher: CURRENT.cipher)

      if PREVIOUS.secret.present?
        previous_secret = self.generate_secret(T.must(PREVIOUS.secret), T.must(PREVIOUS.iterations), T.must(PREVIOUS.cipher), salt:)
        encryptor.rotate previous_secret, cipher: T.must(PREVIOUS.cipher)
      end

      encryptor
    end

    private

    sig { params(secret: String, iterations: Integer, cipher: String, salt: String).returns(String) }
    def generate_secret(secret, iterations, cipher, salt:)
      key_generator = ActiveSupport::KeyGenerator.new(secret, iterations:)
      key_len = ActiveSupport::MessageEncryptor.key_len(cipher)
      secret = key_generator.generate_key(salt, key_len)

      secret
    end
  end
end
