# seed stripe record payment methods
StripeRecord::PaymentMethod.seed do |s|
  s.id = '243e92e6-a089-4836-95c9-a1da1190aec9'
  s.tenant_id = 'sample'
  s.remote_id = 'pm_1SLha9LtOmpZVCAzUfcJbtMD'
  s.user_id = '04df2296-8d2c-4d78-8e74-334ad06ac7cc'
  s.setup_intent_id = 'ac0ea838-15c1-4f51-9fd1-bea7977e1d15'
  s.type = 'card'
  s.billing_details = {"name"=>nil, "email"=>nil, "phone"=>nil, "tax_id"=>nil, "address"=>{"city"=>nil, "line1"=>nil, "line2"=>nil, "state"=>nil, "country"=>nil, "postal_code"=>"15556"}}
  s.card = {"brand"=>"visa", "last4"=>"4242", "checks"=>{"cvc_check"=>"pass", "address_line1_check"=>nil, "address_postal_code_check"=>"pass"}, "wallet"=>nil, "country"=>"US", "funding"=>"credit", "exp_year"=>2026, "networks"=>{"available"=>["visa"], "preferred"=>nil}, "exp_month"=>4, "fingerprint"=>"4wb04V4TCD4A2sUa", "display_brand"=>"visa", "generated_from"=>nil, "regulated_status"=>"unregulated", "three_d_secure_usage"=>{"supported"=>true}}
  s.customer_id = 'cus_TII7mZlaM5cUfS'
  s.detached_at = nil
  s.api_key_account_id = '02ff0a8c-9e4d-49f5-b52b-cc7d5a82e904'
  s.connect_account_id = nil
  s.charge_type = nil
end
