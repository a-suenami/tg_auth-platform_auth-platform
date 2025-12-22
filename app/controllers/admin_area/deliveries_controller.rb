# typed: true

module AdminArea
  class DeliveriesController < ApplicationController
    require_feature :delivery

    before_action :set_delivery, only: [:show, :edit, :update, :destroy, :publish, :cancel, :pause, :resume]
    before_action :load_form_data, only: [:new, :create, :edit, :update]
    before_action :ensure_draft, only: [:edit, :update, :destroy, :publish]

    def index
      query = Delivery.includes(:template, :user_tags, :schedule, :birthday).ordered.search_by_name(params[:q])
      query = filter_by_status(query) if params[:status].present?
      @pagy, @deliveries = pagy(query, items: 10)
    end

    def show
      # Sync results from Blastengine if applicable (real-time on UI view)
      sync_blastengine_results

      @target_users = target_users_for_delivery(@delivery)
      @events = @delivery.delivery_events.includes(:admin).ordered

      # For birthday: load delivery history grouped by date
      @delivery_history = load_delivery_history if @delivery.birthday_type?
    end

    def new
      @delivery = Delivery.new
    end

    def edit; end

    def create
      @delivery = Delivery.new(delivery_params)
      @delivery.user_tag_ids = user_tag_ids_from_params

      service = Deliveries::CreateService.new(
        delivery: @delivery,
        admin: T.must(current_admin),
        delivery_type: delivery_type_from_params,
        schedule_params: schedule_params,
        birthday_params: birthday_params,
      )

      if service.execute
        redirect_to admin_area_delivery_path(@delivery), notice: t('admin_area.deliveries.created')
      else
        render :new, status: :unprocessable_entity
      end
    end


    def update
      service = Deliveries::UpdateService.new(
        delivery: @delivery,
        admin: T.must(current_admin),
        delivery_params: delivery_params.to_h.symbolize_keys,
        new_tag_ids: user_tag_ids_from_params,
        schedule_params: schedule_params,
        birthday_params: birthday_params,
      )

      if service.execute
        redirect_to admin_area_delivery_path(@delivery), notice: t('admin_area.deliveries.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @delivery.destroy!
      redirect_to admin_area_deliveries_path, notice: t('admin_area.deliveries.destroyed'), status: :see_other
    end

    def publish
      service = Deliveries::PublishService.new(delivery: @delivery, admin: T.must(current_admin))

      if service.execute
        redirect_to admin_area_delivery_path(@delivery), notice: t('admin_area.deliveries.published')
      else
        redirect_to admin_area_delivery_path(@delivery), alert: t('admin_area.deliveries.errors.publish_failed')
      end
    end

    def cancel
      service = Deliveries::FixedTime::CancelService.new(delivery: @delivery, admin: T.must(current_admin))

      if service.execute
        redirect_to admin_area_delivery_path(@delivery), notice: t('admin_area.deliveries.cancelled')
      else
        redirect_to admin_area_delivery_path(@delivery), alert: t('admin_area.deliveries.errors.cannot_cancel')
      end
    end

    def pause
      service = Deliveries::Birthday::PauseService.new(delivery: @delivery, admin: T.must(current_admin))

      if service.execute
        redirect_to admin_area_delivery_path(@delivery), notice: t('admin_area.deliveries.paused')
      else
        redirect_to admin_area_delivery_path(@delivery), alert: t('admin_area.deliveries.errors.cannot_pause')
      end
    end

    def resume
      service = Deliveries::Birthday::ResumeService.new(delivery: @delivery, admin: T.must(current_admin))

      if service.execute
        redirect_to admin_area_delivery_path(@delivery), notice: t('admin_area.deliveries.resumed')
      else
        redirect_to admin_area_delivery_path(@delivery), alert: t('admin_area.deliveries.errors.cannot_resume')
      end
    end

    private

    def set_delivery
      @delivery = Delivery.includes(:schedule, :birthday).find(params[:id])
    end

    def load_form_data
      @templates = Template.with_mail.select { |t| t.latest_published_version.present? }
      @user_tags = UserTag.ordered
    end

    def ensure_draft
      return if draft_status?

      error_key = case action_name
                  when 'edit', 'update' then 'draft_only_edit'
                  when 'destroy' then 'draft_only_delete'
                  when 'publish' then 'draft_only_publish'
      end

      redirect_path = action_name == 'destroy' ? admin_area_deliveries_path : admin_area_delivery_path(@delivery)
      redirect_to redirect_path, alert: t("admin_area.deliveries.errors.#{error_key}")
    end

    def delivery_params
      permitted_params.slice(:name, :template_id)
    end

    # Permit all form params to suppress warnings (accessed via helper methods)
    def permitted_params
      params.require(:delivery).permit(
        :name, :template_id,
        :delivery_type, :scheduled_at,
        :birthday_offset_days, :birthday_delivery_time,
        user_tag_ids: [],
      )
    end

    def user_tag_ids_from_params
      permitted_params[:user_tag_ids]&.reject(&:blank?) || []
    end

    def delivery_type_from_params
      permitted_params[:delivery_type] || 'schedule'
    end

    def schedule_params
      scheduled_at = permitted_params[:scheduled_at]
      return {} if scheduled_at.blank?

      { scheduled_at: Time.iso8601(scheduled_at) }
    rescue ArgumentError
      {}
    end

    def birthday_params
      {
        offset_days: permitted_params[:birthday_offset_days] || 0,
        delivery_time: permitted_params[:birthday_delivery_time] || '09:00',
      }
    end

    def draft_status?
      (@delivery.schedule&.draft? || @delivery.birthday&.draft?) == true
    end

    def filter_by_status(query)
      status = params[:status]
      query.left_joins(:schedule, :birthday)
           .where('delivery_schedules.status = ? OR delivery_birthdays.status = ?', status, status)
    end

    def target_users_for_delivery(delivery)
      return User.none if delivery.user_tags.empty?

      User
        .joins(:tag_assignments)
        .where(tag_assignments: { user_tag_id: delivery.user_tag_ids })
        .distinct
        .limit(100)
    end

    # Sync delivery results from Blastengine on UI view (real-time)
    # Only syncs if:
    # - Has blastengine_delivery_id (delivery was sent to Blastengine)
    # - Status is appropriate for sync
    #   - Schedule: 'delivering' or 'delivered' (one-time delivery)
    #   - Birthday: 'delivering' or 'ongoing' (recurring, sync recent results for open tracking)
    def sync_blastengine_results
      schedule = @delivery.schedule
      birthday = @delivery.birthday

      if schedule&.blastengine_delivery_id.present? && %w[delivering delivered].include?(schedule.status)
        Deliveries::FixedTime::ConfirmResultService.new(schedule: schedule).execute
      elsif birthday.present? && %w[delivering ongoing].include?(birthday.status)
        sync_birthday_results
      end
    rescue StandardError => e
      Rails.logger.warn("[DeliveriesController] Blastengine sync failed: #{e.message}")
      # Don't raise - show page with stale data rather than error
    end

    # Sync recent birthday delivery results (open tracking updates over time)
    def sync_birthday_results
      api = Blastengine::API.new

      # Sync recent results (last 7 days) for open tracking updates
      recent_results = @delivery.delivery_results
                                .where('delivery_date >= ?', 7.days.ago.to_date)
                                .where.not(blastengine_delivery_id: nil)

      recent_results.each do |result|
        detail = api.delivery_detail(delivery_id: result.blastengine_delivery_id.to_i)
        result.update!(
          total_count: detail['total_count'] || 0,
          sent_count: detail['sent_count'] || 0,
          drop_count: detail['drop_count'] || 0,
          soft_error_count: detail['soft_error_count'] || 0,
          hard_error_count: detail['hard_error_count'] || 0,
          open_count: detail['open_count'] || 0,
          synced_at: Time.current,
        )
      end
    end

    # Load delivery history for birthday deliveries (grouped by date)
    # Returns array of hashes: [{ date:, result:, recipients: }]
    def load_delivery_history
      results = @delivery.delivery_results.order(delivery_date: :desc).limit(30)

      results.map do |result|
        recipients = @delivery.delivery_recipients
                              .for_date(result.delivery_date)
                              .includes(user: :user_profile)
                              .order(status: :asc)
        {
          date: result.delivery_date,
          result: result,
          recipients: recipients,
        }
      end
    end
  end
end
