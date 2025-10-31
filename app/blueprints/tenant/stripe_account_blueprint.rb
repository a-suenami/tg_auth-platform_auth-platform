# typed: false
# frozen_string_literal: true

class Tenant::StripeAccountBlueprint < ApplicationBlueprint
  fields :tenant_id

  field :type do |obj, _options|
    obj.class.name
  end

  field :publishable_key do |tenant_stripe_account|
    tenant_stripe_account&.stripe_account&.api_key&.publishable_key
  end
end
