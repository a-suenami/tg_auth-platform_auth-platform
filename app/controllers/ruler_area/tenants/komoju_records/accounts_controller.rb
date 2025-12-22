# typed: false
# frozen_string_literal: true

module RulerArea
  module Tenants
    module KomojuRecords
      class AccountsController < RulerArea::Tenants::ApplicationController
        before_action :set_komoju_account, only: [:show, :edit, :update, :destroy]

        def index
          @komoju_accounts = KomojuRecord::Account.all
          @pagy, @komoju_accounts = pagy @komoju_accounts
        end

        def show
          @komoju_webhook_url = build_komoju_webhook_url
        end

        def new
          @komoju_account = KomojuRecord::Account.new(tenant_id: @tenant.id)
        end

        def edit
        end

        def create
          @komoju_account = KomojuRecord::Account.new(komoju_account_params.merge(tenant_id: @tenant.id))
          @komoju_account.webhook_secret = generate_webhook_secret

          if @komoju_account.save
            redirect_to ruler_area_tenant_komoju_records_account_path(@tenant, @komoju_account), notice: 'Komoju account was successfully created.'
          else
            render :new, status: :unprocessable_entity
          end
        end

        def update
          if @komoju_account.update(komoju_account_params)
            redirect_to ruler_area_tenant_komoju_records_accounts_path(@tenant), notice: 'Komoju account was successfully updated.'
          else
            render :edit, status: :unprocessable_entity
          end
        end

        def destroy
          if @komoju_account.destroy
            redirect_to ruler_area_tenant_komoju_records_accounts_path(@tenant), notice: 'Komoju account was successfully destroyed.'
          else
            redirect_to ruler_area_tenant_komoju_records_accounts_path(@tenant), alert: 'Failed to destroy komoju account.'
          end
        end

        private

        def set_komoju_account
          @komoju_account = KomojuRecord::Account.find(params[:id])
        end

        def komoju_account_params
          params.require(:komoju_record_account).permit(
            :remote_id,
            :display_name,
            :secret_key,
            :webhook_secret,
          )
        end

        def generate_webhook_secret
          "whsec_#{SecureRandom.hex(32)}"
        end

        def build_komoju_webhook_url
          if Rails.env.development?
            "http://#{@tenant.id}.localhost:3000/webhook/komoju"
          else
            "https://#{@tenant.domain}/webhook/komoju"
          end
        end
      end
    end
  end
end
