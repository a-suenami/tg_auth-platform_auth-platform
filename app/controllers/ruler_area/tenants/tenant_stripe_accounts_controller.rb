# typed: false
# frozen_string_literal: true

module RulerArea
  module Tenants
    class TenantStripeAccountsController < RulerArea::Tenants::ApplicationController
      before_action :set_tenant_stripe_account, only: [:index, :show, :edit, :update, :destroy]

      def index
      end

      def show
      end

      def new
        @tenant_stripe_account = @tenant.build_tenant_stripe_account
      end

      def edit
      end

      def create
        @tenant_stripe_account = @tenant.build_tenant_stripe_account(tenant_stripe_account_params)

        if @tenant_stripe_account.save
          redirect_to ruler_area_tenant_tenant_stripe_account_path(@tenant), notice: 'Tenant stripe account was successfully created.'
        else
          render :new, status: :unprocessable_entity
        end
      end

      def update
        if @tenant_stripe_account.update(tenant_stripe_account_params)
          redirect_to ruler_area_tenant_tenant_stripe_account_path(@tenant), notice: 'Tenant stripe account was successfully updated.'
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @tenant_stripe_account.destroy
        redirect_to ruler_area_tenant_tenant_stripe_account_path(@tenant), notice: 'Tenant stripe account was successfully destroyed.'
      end

      private

      def set_tenant_stripe_account
        @tenant_stripe_account = @tenant.tenant_stripe_account
        # nilの場合は新規作成にリダイレクト
        if @tenant_stripe_account.nil?
          redirect_to new_ruler_area_tenant_tenant_stripe_account_path(@tenant), notice: 'Tenant Stripe Account not found. Please create one.'
        end
      end

      def tenant_stripe_account_params
        params.require(:tenant_stripe_account).permit(:stripe_account_id, :charge_type, :fee_rate_percentage, :tax_rate_id, :webhook_secret, :membership_grace_period_minutes)
      end
    end
  end
end
