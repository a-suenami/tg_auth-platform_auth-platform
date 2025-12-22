# typed: false

# ==============================================================================
# lib/monkey_patches/enumerize.rb
# ==============================================================================
class Stripe::Account
  def business_profile; end
end
