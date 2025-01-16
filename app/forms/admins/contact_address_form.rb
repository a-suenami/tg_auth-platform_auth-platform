# typed: true

module Admins
  class ContactAddressForm < ApplicationForm
    attribute :id
    attribute :user_id
    attribute :zip_code
    attribute :prefecture_code
    attribute :city
    attribute :street
    attribute :building
    attribute :phone_number
    attribute :country_code, default: 'JP'

    validates :country_code, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }, allow_blank: true # rubocop:disable Naming/VariableNumber
    validates :zip_code, format: { with: /\A\d{3}-\d{4}\z/ }, allow_blank: true
    validates :phone_number, phone: { allow_blank: true }

    attr_accessor :user, :tenant_id

    def self.build(user_id:, id: nil, params: nil)
      instance = new(id:, user_id:)

      if id
        contact_address = ContactAddress.find(id)

        instance.zip_code = contact_address&.zip_code
        instance.prefecture_code = contact_address&.prefecture_code
        instance.city = contact_address&.city
        instance.street = contact_address&.street
        instance.building = contact_address&.building
        instance.phone_number = contact_address&.phone_number
        instance.country_code = contact_address&.country_code
      end

      instance.attributes = permit_params(params) if params.present?
      instance.user = User.find(user_id)
      instance.tenant_id = instance.user.tenant_id
      instance
    end

    def perform!
      if edit?
        update_contact_address
      else
        create_contact_address
      end
    rescue => e
      errors.add(:base, e.message)
    end

    def edit?
      id.present?
    end

    def self.permit_params(params)
      params.require(:admins_contact_address_form).permit(
        :zip_code,
        :prefecture_code,
        :city,
        :street,
        :building,
        :phone_number,
        :country_code,
      )
    end

    def update_contact_address
      contact_address = ContactAddress.find(id)
      contact_address.update!(
        zip_code:,
        prefecture_code:,
        city:,
        street:,
        building:,
        phone_number:,
        country_code:,
      )
    end

    def create_contact_address
      user.create_contact_address(
        tenant_id:,
        user_id:,
        zip_code:,
        prefecture_code:,
        city:,
        street:,
        building:,
        phone_number:,
        country_code:,
      )
    end

    private_class_method :permit_params
  end
end
