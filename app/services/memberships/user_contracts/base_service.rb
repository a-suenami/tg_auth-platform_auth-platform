# typed: false

# ==============================================================================
# app - services - user stripe - base service
# ==============================================================================
module Memberships::UserContracts
  class BaseService < ::BaseService

    def validate_contractable(user:, membership_plan:, payment_method:)
      # 2. userに紐づくMembershipsUserを検索し、@membership_planに紐づくmembershipにすでに契約していないか確認する
      existing_membership_users = user.membership_users.joins(:membership)
                                              .joins('INNER JOIN memberships__plan_components ON memberships.id = memberships__plan_components.membership_id')
                                              .where(memberships__plan_components: { membership_plan_id: membership_plan.id })

      if existing_membership_users.exists?
        raise Exceptions::Payment::AlreadyHaveMembership
      end

      # 3. 与えられたmembership_plan.plan_payment_methodにcredit_cartがあるか確認
      unless membership_plan.plan_payment_methods.exists?(payment_type: payment_method)
        raise Exceptions::Payment::PaymentMethodNotAvailable
      end
    end
  end
end
