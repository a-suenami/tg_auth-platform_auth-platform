# typed: true

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

  validates :zip_code, presence: true, if: ->(obj) { obj.required_on_domestic_address?(:contact_address, :zip_code) }
  validates :prefecture_code, presence: true, if: ->(obj) { obj.required_on_domestic_address?(:contact_address, :prefecture_code) }
  validates :city, presence: true, if: ->(obj) { obj.required_on_domestic_address?(:contact_address, :city) }
  validates :street, presence: true, if: ->(obj) { obj.required_on_domestic_address?(:contact_address, :street) }
  validates :building, presence: true, if: ->(obj) { obj.required_on_domestic_address?(:contact_address, :building) }
  validates :phone_number, presence: true, if: ->(obj) { obj.required?(:contact_address, :phone_number) }
  validates :country_code, presence: true, if: ->(obj) { obj.required?(:contact_address, :country_code) }

  validates :country_code, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }, allow_blank: true # rubocop:disable Naming/VariableNumber
  validates :zip_code, format: { with: /\A\d{3}-\d{4}\z/ }, allow_blank: true
  validates :phone_number, phone: { allow_blank: true }

  def domestic_address?
    country_code == 'JP'
  end

  attr_accessor :current_profile_field_rules, :user, :tenant_id

  def self.build(user_id:, profile_field_rules:, id: nil, params: nil)
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

    if params.present?
      permit_contact_address_params = permit_params(params)[:contact_address_attributes]
      if permit_contact_address_params.present?
        instance.attributes = permit_contact_address_params
      end
    end

    instance.current_profile_field_rules = profile_field_rules
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
    params.require(:user).permit(
      contact_address_attributes: [
        :zip_code,
        :prefecture_code,
        :city,
        :street,
        :building,
        :phone_number,
        :country_code,
      ],
    )
  end

  def update_contact_address
    contact_address = UserProfile.find(id)

    update_field(contact_address, :zip_code, zip_code)
    update_field(contact_address, :prefecture_code, prefecture_code)
    update_field(contact_address, :city, city)
    update_field(contact_address, :street, street)
    update_field(contact_address, :building, building)
    update_field(contact_address, :phone_number, phone_number)
    update_field(contact_address, :country_code, country_code)

    contact_address.save!
  end

  def create_contact_address
    # 全ての属性が空の場合は何もしない
    return if all_attributes_blank?

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


  def required?(table_name, field)
    @current_profile_field_rules[table_name][field][:required]
  end

  def required_on_domestic_address?(table_name, field)
    country_code == 'JP' && @current_profile_field_rules[table_name][field][:required]
  end

  def editable?(table_name, field)
    @current_profile_field_rules[table_name][field][:editable]
  end

  def update_field(record, field, new_value)
    return unless record.respond_to?(field) # フィールドが存在しない場合はスキップ

    current_value = record.public_send(field)
    if current_value.blank? || editable?(:contact_addresss, field)
      record.public_send("#{field}=", new_value)
    end
  end

  def all_attributes_blank?
    %i[zip_code prefecture_code city street building phone_number country_code].all? do |attr|
      send(attr).blank?
    end
  end

  private_class_method :permit_params
end
