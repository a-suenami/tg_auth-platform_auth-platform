# typed: false
# frozen_string_literal: true

module RulerArea
  module Tenants
    class TenantKomojuAccountsController < RulerArea::Tenants::ApplicationController
      before_action :set_tenant_komoju_account, only: [:show, :edit, :update, :destroy]

      def show
      end

      def new
        @tenant_komoju_account = @tenant.build_tenant_komoju_account
        @komoju_accounts = KomojuRecord::Account.where(tenant_id: @tenant.id)
      end

      def edit
        @komoju_accounts = KomojuRecord::Account.where(tenant_id: @tenant.id)
      end

      def create
        @tenant_komoju_account = @tenant.build_tenant_komoju_account(tenant_komoju_account_params)

        if @tenant_komoju_account.save
          redirect_to ruler_area_tenant_tenant_komoju_account_path(@tenant), notice: 'Tenant Komoju account was successfully created.'
        else
          @komoju_accounts = KomojuRecord::Account.where(tenant_id: @tenant.id)
          render :new, status: :unprocessable_entity
        end
      end

      def update
        if @tenant_komoju_account.update(tenant_komoju_account_params)
          redirect_to ruler_area_tenant_tenant_komoju_account_path(@tenant), notice: 'Tenant Komoju account was successfully updated.'
        else
          @komoju_accounts = KomojuRecord::Account.where(tenant_id: @tenant.id)
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @tenant_komoju_account.destroy
        redirect_to new_ruler_area_tenant_tenant_komoju_account_path(@tenant), notice: 'Tenant Komoju account was successfully destroyed.'
      end

      private

      def set_tenant_komoju_account
        @tenant_komoju_account = @tenant.tenant_komoju_account
        # If nil, redirect to new
        if @tenant_komoju_account.nil?
          redirect_to new_ruler_area_tenant_tenant_komoju_account_path(@tenant), notice: 'Tenant Komoju Account not found. Please create one.'
        end
      end

      def tenant_komoju_account_params
        params.require(:tenant_komoju_account).permit(
          :komoju_account_id,
          :enabled,
          :default_expiry_days,
        )
      end
    end
  end
end
