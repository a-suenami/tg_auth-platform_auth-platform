# typed: strict

# ==============================================================================
# app/controllers/ruler_area/tenants/stripe_records/products_controller.rb
# ==============================================================================
module RulerArea
  class Tenants::StripeRecords::ProductsController < RulerArea::Tenants::ApplicationController
    extend T::Sig

    sig { void }
    def index
      @stripe_record_products = T.let(StripeRecord::Product.all, T.untyped)
    end

    sig { void }
    def show
      @stripe_record_product = T.let(StripeRecord::Product.find(params[:id]), T.untyped)
    end

    sig { void }
    def preview
      @stripe_record_product = T.let(
        StripeRecords::Products::RetrieveService.new(tenant_stripe_account: T.must(Tenant.current!.tenant_stripe_account)).execute(stripe_product_id: params[:stripe_product_id]), T.untyped,
      )

      render :preview
    rescue => e
      Sentry.capture_exception(e)
      redirect_to({ action: :index }, alert: '同期に失敗しました。API キーの設定などを確認してください')
    end

    sig { void }
    def sync
      StripeRecords::Products::SyncProductAndPlansService.new(tenant_stripe_account: T.must(Tenant.current!.tenant_stripe_account)).execute(stripe_product_id: params[:stripe_product_id])

      redirect_to({ action: :index }, notice: '同期が完了しました')
    rescue => e
      Sentry.capture_exception(e)
      redirect_to({ action: :index }, alert: '同期に失敗しました。API キーの設定などを確認してください')
    end

    sig { void }
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
