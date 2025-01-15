# typed: true

class UserForm < ApplicationForm
  attribute :user_profile_form
  attribute :contact_address_form
  attr_accessor :current_profile_field_rules
  attr_accessor :user

  DEFAULT_PROFILE_FIELD_RULES = {
    user_profiles: {
      first_name: {
        required: true,
        hidden: false,
        editable: false,
      },
      last_name: {
        required: true,
        hidden: false,
        editable: true,
      },
      first_name_kana: {
        required: true,
        hidden: false,
        editable: false,
      },
      last_name_kana: {
        required: true,
        hidden: false,
        editable: true,
      },
      birth_date: {
        required: true,
        hidden: false,
        editable: false,
      },
      gender: {
        required: true,
        hidden: false,
        editable: false,
      },
    },
    contact_address: {
      zip_code: {
        required: true,
        hidden: false,
        editable: true,
      },
      prefecture_code: {
        required: true,
        hidden: false,
        editable: true,
      },
      city: {
        required: true,
        hidden: false,
        editable: true,
      },
      street: {
        required: true,
        hidden: false,
        editable: true,
      },
      building: {
        required: false,
        hidden: false,
        editable: true,
      },
      phone_number: {
        required: false,
        hidden: false,
        editable: true,
      },
      country_code: {
        required: false, # デフォルトでJP
        hidden: false,
        editable: true,
      },
    },
  }.freeze

  def self.build(id:, params: nil)
    user = User.find(id)
    tenant = user.tenant
    merged_rules = if tenant.tenant_setting&.profile_field_rules.present?
      persed_rules = safe_parse_json(tenant.tenant_setting&.profile_field_rules)
      deep_merge(DEFAULT_PROFILE_FIELD_RULES, persed_rules)
    else
      DEFAULT_PROFILE_FIELD_RULES
    end

    user_profile_form = UserProfileForm.build(
      id: user.user_profile&.id,
      params:,
      user_id: id,
      profile_field_rules: merged_rules,
    )

    contact_address_form = ContactAddressForm.build(
      id: user.contact_address&.id,
      params:,
      user_id: id,
      profile_field_rules: merged_rules,
    )

    new(
      user_profile_form:,
      contact_address_form:,
      user:,
      current_profile_field_rules: merged_rules,
    )
  end

  def perform!
    ActiveRecord::Base.transaction do
      unless user_profile_form.valid? && contact_address_form.valid?
        propagate_errors
        raise ActiveRecord::Rollback
      end

      user_profile_form.perform!
      contact_address_form.perform!
      check_and_enable_user
    end
  rescue => e
    errors.add(:base, e.message)
  end

  def valid?
    # 両方のエラーを出すため、個別に呼び出し
    user_profile_form_valid = user_profile_form.valid?
    contact_address_form_valid = contact_address_form.valid?
    user_form_valid = user_profile_form_valid && contact_address_form_valid
    if user_form_valid == false
      propagate_errors
    end
    user_form_valid
  end

  def check_and_enable_user
    return true if user.enabled

    # 1. パスワードが登録済
    return false if user.password_digest.blank?
    # 3. 電話番号確認済(必須の場合)
    return false if user.tenant&.sms_verification_required && (user.sms_verified == false)
    # 4. 必須フィールドがすべて設定されているか確認
    return false unless check_required_fields_filled?

    user.enabled = true
    user.save!
  end


  private

  def self.deep_merge(defaults, overrides)
    defaults.merge(overrides) do |_key, default_val, override_val|
      if default_val.is_a?(Hash) && override_val.is_a?(Hash)
        deep_merge(default_val, override_val)
      else
        override_val
      end
    end
  end

  def self.safe_parse_json(json_string)
    return {} if json_string.blank?

    JSON.parse(json_string, symbolize_names: true)
  rescue JSON::ParserError
    DEFAULT_PROFILE_FIELD_RULES
  end

  # 必須フィールドがすべて設定されているかチェック
  def check_required_fields_filled?
    # relaodしないと、さっきの更新が反映されない
    user.reload
    # プロファイル情報を確認
    user_profile = user.reload.user_profile
    return false unless check_fields(user_profile, current_profile_field_rules[:user_profiles])

    # 住所情報を確認
    contact_address = user.contact_address
    return false unless check_fields(contact_address, current_profile_field_rules[:contact_address])

    true
  end

  def check_fields(record, field_rules)
    field_rules.each do |field, attributes|
      next unless attributes['required']

      value = record&.public_send(field)
      return false if value.blank?
    end

    true
  end

  def propagate_errors
    user_profile_form.errors.each do |error|
      errors.add("user_profile.#{error.attribute}", error.message)
    end

    contact_address_form.errors.each do |error|
      errors.add("contact_address.#{error.attribute}", error.message)
    end
  end

  private_class_method :deep_merge, :safe_parse_json
end
