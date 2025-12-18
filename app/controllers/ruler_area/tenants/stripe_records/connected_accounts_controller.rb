# typed: false
# frozen_string_literal: true

module RulerArea
  module Tenants
    module StripeRecords
      class ConnectedAccountsController < RulerArea::Tenants::ApplicationController
        before_action :set_connected_account, only: [:show, :destroy, :onboarding, :refresh]
        before_action :set_platform_accounts, only: [:index, :new, :create]

        def index
          @connected_accounts = StripeRecord::Account.where.not(controlling_platform_id: nil)
          @pagy, @connected_accounts = pagy @connected_accounts
        end

        def show
        end

        def new
          @connected_account = StripeRecord::Account.new(tenant_id: @tenant.id)
        end

        def create
          platform_account = StripeRecord::Account.find(params[:controlling_platform_id])

          service = ::StripeRecords::ConnectedAccounts::CreateService.new(
            platform_account: platform_account,
            tenant: @tenant,
          )
          result = service.execute

          if result.ok?
            @connected_account = result.ok_inner
            redirect_to onboarding_ruler_area_tenant_stripe_records_connected_account_path(@tenant, @connected_account),
              notice: 'Connected accountが作成されました。オンボーディングを続けてください。'
          else
            @connected_account = StripeRecord::Account.new(tenant_id: @tenant.id)
            flash.now[:alert] = result.err_inner
            render :new, status: :unprocessable_entity
          end
        end

        def destroy
          if @connected_account.destroy
            redirect_to ruler_area_tenant_stripe_records_connected_accounts_path(@tenant),
              notice: 'Connected accountが削除されました。'
          else
            redirect_to ruler_area_tenant_stripe_records_connected_accounts_path(@tenant),
              alert: 'Connected accountの削除に失敗しました。'
          end
        end

        # オンボーディングURLを生成してリダイレクト
        def onboarding
          service = ::StripeRecords::ConnectedAccounts::CreateAccountLinkService.new(
            connected_account: @connected_account,
            refresh_url: refresh_ruler_area_tenant_stripe_records_connected_account_url(@tenant, @connected_account),
            return_url: ruler_area_tenant_stripe_records_connected_account_url(@tenant, @connected_account),
          )
          result = service.execute

          if result.ok?
            redirect_to result.ok_inner.url, allow_other_host: true
          else
            redirect_to ruler_area_tenant_stripe_records_connected_account_path(@tenant, @connected_account),
              alert: result.err_inner
          end
        end

        # オンボーディングが中断された場合のリフレッシュ
        def refresh
          # アカウント情報を更新
          @connected_account.save # set_attributesコールバックで最新情報を取得

          service = ::StripeRecords::ConnectedAccounts::CreateAccountLinkService.new(
            connected_account: @connected_account,
            refresh_url: refresh_ruler_area_tenant_stripe_records_connected_account_url(@tenant, @connected_account),
            return_url: ruler_area_tenant_stripe_records_connected_account_url(@tenant, @connected_account),
          )
          result = service.execute

          if result.ok?
            redirect_to result.ok_inner.url, allow_other_host: true
          else
            redirect_to ruler_area_tenant_stripe_records_connected_account_path(@tenant, @connected_account),
              alert: result.err_inner
          end
        end

        private

        def set_connected_account
          @connected_account = StripeRecord::Account.find(params[:id])
        end

        def set_platform_accounts
          @platform_accounts = StripeRecord::Account.where(controlling_platform_id: nil)
        end
      end
    end
  end
end
