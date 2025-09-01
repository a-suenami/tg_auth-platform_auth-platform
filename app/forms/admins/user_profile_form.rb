# typed: true

module Admins
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

    validates :first_name, format: { with: /\A[\p{Hiragana}\p{Katakana}\p{Han}ー々a-zA-Z]+\z/, message: I18n.t('activerecord.errors.models.user.attributes.first_name.format') }, allow_blank: true
    validates :last_name, format: { with: /\A[\p{Hiragana}\p{Katakana}\p{Han}ー々a-zA-Z]+\z/, message: I18n.t('activerecord.errors.models.user.attributes.last_name.format') }, allow_blank: true
    validates :first_name_kana, format: { with: /\A[\p{Katakana}ー]+\z/, message: I18n.t('activerecord.errors.models.user.attributes.first_name_kana.format') }, allow_blank: true
    validates :last_name_kana, format: { with: /\A[\p{Katakana}ー]+\z/, message: I18n.t('activerecord.errors.models.user.attributes.last_name_kana.format') }, allow_blank: true
    validates :birth_date, comparison: { less_than: Time.zone.today }, allow_blank: true
    enumerize :gender, in: [:male, :female, :other]

    attr_accessor :user, :tenant_id

    def self.build(user_id:, id: nil, params: nil)
      user = User.find(user_id)
      user.tenant

      instance = new(id:, user_id:)

      if id
        user_profile = UserProfile.find(id)

        instance.first_name = user_profile.first_name
        instance.last_name = user_profile.last_name
        instance.first_name_kana = user_profile.first_name_kana
        instance.last_name_kana = user_profile.last_name_kana
        instance.birth_date = user_profile.birth_date
        instance.gender = user_profile.gender
      end

      instance.attributes = permit_params(params) if params.present?
      instance.birth_date = instance.birth_date&.to_date # バリデーションためにDate型に変換
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
      params.require(:admins_user_profile_form).permit(
        :first_name,
        :last_name,
        :first_name_kana,
        :last_name_kana,
        :birth_date,
        :gender,
      )
    end

    def update_user_profile
      user_profile = UserProfile.find(id)

      user_profile.update!(
        first_name:,
        last_name:,
        first_name_kana:,
        last_name_kana:,
        birth_date:,
        gender:,
      )
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
    end

    private_class_method :permit_params
  end
end
