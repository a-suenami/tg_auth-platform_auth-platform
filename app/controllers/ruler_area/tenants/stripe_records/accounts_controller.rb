# typed: false
# frozen_string_literal: true

module RulerArea
  module Tenants
    module StripeRecords
      class AccountsController < RulerArea::Tenants::ApplicationController
        before_action :set_stripe_account, only: [:show, :edit, :update, :destroy]

        def index
          @stripe_accounts = StripeRecord::Account.all
          @pagy, @stripe_accounts = pagy @stripe_accounts
        end

        def show
        end

        def new
          @stripe_account = StripeRecord::Account.new(tenant_id: @tenant.id)
          # Initialize API key for the account
          @stripe_account.build_api_key(tenant_id: @tenant.id)
        end

        def edit
        end

        def create
          # First create the API key with the required parameters
          api_key_params = stripe_account_params[:api_key_attributes]
          @api_key = StripeRecord::APIKey.new(
            tenant_id: @tenant.id,
            display_name: api_key_params[:display_name],
            remote_id: api_key_params[:remote_id],
            publishable_key: api_key_params[:publishable_key],
            secret_key: api_key_params[:secret_key],
          )

          if @api_key.save
            # The API key validation automatically creates an account, so we use that one
            @stripe_account = @api_key.account
            # Ensure tenant_id is set on the account
            @stripe_account.tenant_id = @tenant.id

            if @stripe_account.save
              redirect_to ruler_area_tenant_stripe_records_accounts_path(@tenant), notice: 'Stripe account was successfully created.'
            else
              # Add api key errors to the stripe account
              @stripe_account.errors.add(:base, 'Failed to create account')
              @api_key.destroy
              @stripe_account = StripeRecord::Account.new(tenant_id: @tenant.id)
              @stripe_account.build_api_key(tenant_id: @tenant.id)
              render :new, status: :unprocessable_entity
            end
          else
            @stripe_account = StripeRecord::Account.new(tenant_id: @tenant.id)
            @stripe_account.build_api_key(tenant_id: @tenant.id)
            # Transfer API key errors to the stripe account
            @api_key.errors.full_messages.each do |message|
              @stripe_account.errors.add(:api_key, message)
            end
            render :new, status: :unprocessable_entity
          end
        end

        def update
          if @stripe_account.update(stripe_account_params)
            redirect_to ruler_area_tenant_stripe_records_accounts_path(@tenant), notice: 'Stripe account was successfully updated.'
          else
            render :edit, status: :unprocessable_entity
          end
        end

        def destroy
          if @stripe_account.destroy
            redirect_to ruler_area_tenant_stripe_records_accounts_path(@tenant), notice: 'Stripe account was successfully destroyed.'
          else
            redirect_to ruler_area_tenant_stripe_records_accounts_path(@tenant), alert: 'Failed to destroy stripe account.'
          end
        end

        private


        def set_stripe_account
          @stripe_account = StripeRecord::Account.find(params[:id])
        end

        def stripe_account_params
          # Handle both possible parameter names
          account_params = params[:stripe_record_account] || params[:stripe_account]
          account_params.permit(
            api_key_attributes: [
              :display_name,
              :remote_id,
              :publishable_key,
              :secret_key,
            ],
          )
        end
      end
    end
  end
end
