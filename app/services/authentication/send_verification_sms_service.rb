# typed: strict

module Authentication
  class SendVerificationSmsService < BaseService
    extend T::Sig

    # SMS送信対象外の国コードリスト
    EXCLUDED_COUNTRY_CODE = T.let(%w[AF AZ BI BZ ET IQ LB LK LY MG PK PS RU SY TD TJ TN UZ ZM].freeze, T::Array[String])

    sig { params(phone_number: String, user_id: String, ip_address: String, delivery_type: T.nilable(String), verifier_type: Symbol).returns(User) }
    def execute!(phone_number:, user_id:, ip_address:, delivery_type:, verifier_type: :registration)
      # SMS送信対象外の国コードチェック
      raise Exceptions::Authentication::NoSmsSupportedCountry if excluded_country_code?(phone_number)

      user = User.active.find user_id

      sms_rate_limit(phone_number:, user:, _ip_address: ip_address)

      ActiveRecord::Base.transaction do
        sms_verifier = Users::SmsVerifier.new(user:, phone_number:, verifier_type:, ip_address:)
        sms_verifier.set_code
        sms_verifier.save!

        # TODO: 1ユーザが送信可能なsmsを制限orクールタイムを設ける。
        send_verification_sms(sms_verifier, delivery_type)
        user
      end
    end

    sig { params(sms_verifier: Users::SmsVerifier, delivery_type: T.nilable(String)).returns(T::Boolean) }
    def send_verification_sms(sms_verifier, delivery_type)
      if !Rails.env.production? && Settings.super_mode == true # SUPER_MODE では送らない
        sleep(rand(0.05..0.1))
        sms_verifier.delivery_type = delivery_type
        sms_verifier.sms_sender = 'super_mode'
        sms_verifier.sms_sid = 'SUPER_MODE'
        return sms_verifier.save
      end

      # 国内電話番号はSmsLink、それ以外はTwilioを使う。
      if PhonyRails.country_code_from_number(sms_verifier.phone_number) == '81'
        response = SmsLink::API.new.send_sms(sms_verifier:, delivery_type:)
        sms_verifier.delivery_type = delivery_type
        sms_verifier.sms_sender = 'smslink'
        sms_verifier.sms_sid = response['verification_code_id']
      else
        response = Twilio::API.new.send_sms_with_twilio_verify(to: T.must(sms_verifier.phone_number), custom_code: sms_verifier.code)
        sms_verifier.sms_sender = 'twilio'
        sms_verifier.sms_sid = response.sid
      end
      sms_verifier.save
    end

    sig { params(phone_number: String, user: T.untyped, _ip_address: String).returns(T.nilable(T::Boolean)) }
    def sms_rate_limit(phone_number:, user:, _ip_address:)
      # 開発環境,staging環境でratelimitが実装されていると検証が大変になるので無効化できるように
      return if Settings.sms.disable_rate_limit

      # 同一電話番号 5件/3hours
      raise Exceptions::Authentication::SmsSendLimit if Users::SmsVerifier.where('created_at > ?', 3.hours.ago).where(phone_number:).count >= 5
      # 同一電話番号 10件/24hours
      raise Exceptions::Authentication::SmsSendLimit if Users::SmsVerifier.where('created_at > ?', 24.hours.ago).where(phone_number:).count >= 10
      # 同一IP      100件/1hours
      # raise Exceptions::Authentication::SmsSendLimit if Users::SmsVerifier.where('created_at > ?', 1.hour.ago).where(ip_address:).count >= 100
      # 同一ユーザ   10件/24hours
      raise Exceptions::Authentication::SmsSendLimit if Users::SmsVerifier.where('created_at > ?', 24.hours.ago).where(user:).count >= 10
    end

    sig { params(phone_number: String).returns(T::Boolean) }
    def excluded_country_code?(phone_number)
      phone = Phonelib.parse(phone_number)

      EXCLUDED_COUNTRY_CODE.intersect?(phone.valid_countries)
    end
  end
end
