# typed: strict

module UserStripe
  class SendRenewSubscriptionEmailService < BaseService
    extend T::Sig

    sig { params(user: User, membership_contract: Membership::Contract).void }
    def execute!(user:, membership_contract:)
      email = user.email
      # email validate
      unless email =~ URI::MailTo::EMAIL_REGEXP
        raise Exceptions::Authentication::InvalidEmail
      end

      send_renew_subscription_email(T.must(email), user, membership_contract)
    end

    sig { params(email: String, _user: User, membership_contract: Membership::Contract).void }
    def send_renew_subscription_email(email, _user, membership_contract)
      # query encode
      contract_term = membership_contract.current_contract_term
      membership_plan = T.must(contract_term).membership_plan
      payment_transaction = membership_contract.payment_transactions.order(created_at: :desc).first
      template_params = {
        membership_plan_name: membership_plan&.name,
        membership_plan_amount: payment_transaction&.paid_amount,
      }.to_query

      User::SendEmailWorker.perform_async(T.must(Tenant.current_id), 'renew_subscription', template_params, email)
    end
  end
end
