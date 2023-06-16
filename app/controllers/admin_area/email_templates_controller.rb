module AdminArea
  class EmailTemplatesController < ApplicationController
    def index
      @email_templates = EmailTemplate.all
      @pagy, @email_templates = pagy @email_templates
    end

    def show
      @email_template = EmailTemplate.find(params[:id])
    end

    def new
      @email_template = EmailTemplate.new
    end

    def create
      @email_template = EmailTemplate.create(email_template_params)
      if @email_template.persisted?
        redirect_to admin_area_email_templates_path, notice: 'EmailTemplate was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @email_template = EmailTemplate.find(params[:id])
    end

    def update
      @email_template = EmailTemplate.find(params[:id])
      if @email_template.update(email_template_params)
        redirect_to admin_area_email_templates_path, notice: 'EmailTemplate was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      email_template = EmailTemplate.find(params[:id])
      email_template.destroy!
      redirect_to admin_area_email_templates_path, notice: 'EmailTemplate was successfully destroyed.',  status: :see_other
    end

    private
    def email_template_params
      params.require(:email_template).permit(:template_type, :name, :subject, :body)
    end
  end
end
