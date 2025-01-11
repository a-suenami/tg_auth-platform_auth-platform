# typed: true

class UserProfileForm < ApplicationForm
  extend Enumerize
  attribute :id
  attribute :user_id
  attribute :first_name
  attribute :last_name
  attribute :first_name_kana
  attribute :last_name_kana
  attribute :birth_date
  attribute :gender

  validates :first_name, presence: true, if: ->(obj) { obj.required?(:user_profiles, :first_name) }
  validates :last_name, presence: true, if: ->(obj) { obj.required?(:user_profiles, :last_name) }
  validates :first_name_kana, presence: true, if: ->(obj) { obj.required?(:user_profiles, :first_name_kana) }
  validates :last_name_kana, presence: true, if: ->(obj) { obj.required?(:user_profiles, :last_name_kana) }
  validates :birth_date, presence: true, if: ->(obj) { obj.required?(:user_profiles, :birth_date) }
  validates :gender, presence: true, if: ->(obj) { obj.required?(:user_profiles, :gender) }
  validates :first_name, format: { with: /\A[\p{Hiragana}\p{Katakana}\p{Han}ー々a-zA-Z]+\z/, message: I18n.t('activerecord.errors.models.user.attributes.first_name.format') }
  validates :last_name, format: { with: /\A[\p{Hiragana}\p{Katakana}\p{Han}ー々a-zA-Z]+\z/, message: I18n.t('activerecord.errors.models.user.attributes.last_name.format') }
  validates :first_name_kana, format: { with: /\A[\p{Katakana}ー]+\z/, message: I18n.t('activerecord.errors.models.user.attributes.first_name_kana.format') }
  validates :last_name_kana, format: { with: /\A[\p{Katakana}ー]+\z/, message: I18n.t('activerecord.errors.models.user.attributes.last_name_kana.format') }
  validates :birth_date, comparison: { less_than: Time.zone.today }
  enumerize :gender, in: [:male, :female, :other]

  attr_accessor :current_profile_field_rules, :user, :tenant_id

  def self.build(user_id:, profile_field_rules:, id: nil, params: nil)
    instance = new(id:, user_id:)

    if id
      user_profile = UserProfile.find(id)

      instance.first_name = user_profile&.first_name
      instance.last_name = user_profile&.last_name
      instance.first_name_kana = user_profile&.first_name_kana
      instance.last_name_kana = user_profile&.last_name_kana
      instance.birth_date = user_profile&.birth_date
      instance.gender = user_profile&.gender
    end

    instance.attributes = permit_params(params)[:user_profile_attributes] if params.present?
    instance.birth_date = instance.birth_date&.to_date # バリデーションためにDate型に変換

    instance.current_profile_field_rules = profile_field_rules
    instance.user = User.find(user_id)
    instance.tenant_id = instance.user.tenant_id
    instance
  end

  def perform!
    if edit?
      update_user_profile
    else
      create_user_profile
    end
  rescue => e
    errors.add(:base, e.message)
  end

  def edit?
    id.present?
  end

  def self.permit_params(params)
    params.require(:user).permit(
      user_profile_attributes: [
        :first_name,
        :last_name,
        :first_name_kana,
        :last_name_kana,
        :birth_date,
        :gender,
      ],
    )
  end

  def update_user_profile
    user_profile = UserProfile.find(id)

    update_field(user_profile, :first_name, first_name)
    update_field(user_profile, :last_name, last_name)
    update_field(user_profile, :first_name_kana, first_name_kana)
    update_field(user_profile, :last_name_kana, last_name_kana)
    update_field(user_profile, :birth_date, birth_date)
    update_field(user_profile, :gender, gender)

    user_profile.save!
  end

  def create_user_profile
    user.create_user_profile(
      tenant_id:,
      user_id:,
      first_name:,
      last_name:,
      first_name_kana:,
      last_name_kana:,
      birth_date:,
      gender:,
    )
    user_profile.save!
  end


  def required?(table_name, field)
    @current_profile_field_rules[table_name][field][:required]
  end

  def editable?(table_name, field)
    @current_profile_field_rules[table_name][field][:editable]
  end

  def update_field(record, field, new_value)
    return unless record.respond_to?(field) # フィールドが存在しない場合はスキップ

    current_value = record.public_send(field)
    if current_value.blank? || editable?(:user_profiles, field)
      record.public_send("#{field}=", new_value)
    end
  end

  private_class_method :permit_params
end
