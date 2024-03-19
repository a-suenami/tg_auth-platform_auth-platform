module RulerArea
  class RulersController < ApplicationController
    def index
      @rulers = Ruler.all
      @pagy, @rulers = pagy @rulers
    end

    def new
      @ruler = Ruler.new
    end

    def create
      if ::Rulers::CreateService.new.execute(email: ruler_params[:email], name: ruler_params[:name])
        redirect_to ruler_area_rulers_path, notice: t('helpers.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def ruler_params
      params.require(:ruler).permit(
        :name,
        :email,
      )
    end
  end
end
