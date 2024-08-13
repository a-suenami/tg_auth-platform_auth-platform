# typed: strict

# ==============================================================================
# app/controllers/ruler_area/tenants/stripe_records/products_controller.rb
# ==============================================================================
module RulerArea
  class Tenants::StripeRecords::ProductsController < RulerArea::Tenants::ApplicationController
    extend T::Sig
    sig { void }
    def index
      @stripe_record_products = StripeRecord::Product.all
    end
    sig { void }
    def show
      @stripe_record_product = StripeRecord::Product.find(params[:id])
    end

    def preview
      @stripe_record_product = StripeRecords::Products::RetrieveService.new(tenant_stripe_account: T.must(Tenant.current!.tenant_stripe_account)).execute(stripe_product_id: params[:stripe_product_id])

      render :preview
    rescue => e
      Sentry.capture_exception(e)
      redirect_to({ action: :index }, alert: '同期に失敗しました。API キーの設定などを確認してください')
    end

    def sync
      StripeRecords::Products::SyncProductAndPlansService.new(tenant_stripe_account: T.must(Tenant.current!.tenant_stripe_account)).execute(stripe_product_id: params[:stripe_product_id])

      redirect_to({ action: :index }, notice: '同期が完了しました')
    rescue => e
      Sentry.capture_exception(e)
      redirect_to({ action: :index }, alert: '同期に失敗しました。API キーの設定などを確認してください')
    end

    def destroy
      # 論理削除
      StripeRecords::Products::DestroyService.new(tenant_stripe_account: T.must(Tenant.current!.tenant_stripe_account)).execute(stripe_record_product_id: params[:id])

      redirect_to({ action: :index }, notice: '商品を削除しました')
    rescue => e
      Sentry.capture_exception(e)
      redirect_to({ action: :index }, alert: '予期せぬエラーにより削除できませんでした')
    end
  end
end
