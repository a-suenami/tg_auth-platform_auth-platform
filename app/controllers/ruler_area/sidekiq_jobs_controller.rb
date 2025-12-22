# typed: true
# frozen_string_literal: true

module RulerArea
  class SidekiqJobsController < ApplicationController
    # Whitelist of allowed Sidekiq jobs
    ALLOWED_JOBS = T.let({
      'ExpireEmailVerifiersWorker' => ExpireEmailVerifiersWorker,
      'User::SendEmailWorker' => User::SendEmailWorker,
      'StripeSubscriptionValidationWorker' => StripeSubscriptionValidationWorker,
      'UserAutoTagging::ApplyWorker' => UserAutoTagging::ApplyWorker,
      'UserAutoTagging::DailyWorker' => UserAutoTagging::DailyWorker,
      'UserAutoTagging::EventWorker' => UserAutoTagging::EventWorker,
      'Deliveries::Birthday::SetupWorker' => Deliveries::Birthday::SetupWorker,
      'Deliveries::ConfirmImportWorker' => Deliveries::ConfirmImportWorker,
      'Deliveries::ConfirmResultWorker' => Deliveries::ConfirmResultWorker,
      'Deliveries::FixedTime::SetupWorker' => Deliveries::FixedTime::SetupWorker,
      'Deliveries::OrchestratorWorker' => Deliveries::OrchestratorWorker,
    }.freeze, T::Hash[String, T.class_of(Sidekiq::Job)],)

    # Hints for each job's expected arguments (shown in dropdown)
    JOB_HINTS = T.let({
      'ExpireEmailVerifiersWorker' => { args: '(不要)', desc: '期限切れのメール認証を削除' },
      'User::SendEmailWorker' => { args: 'tenant_id, template_type, params, send_to', desc: 'ユーザーにメール送信' },
      'StripeSubscriptionValidationWorker' => { args: '(不要)', desc: 'Stripeサブスクリプション検証' },
      'UserAutoTagging::ApplyWorker' => { args: 'user_auto_tagging_id', desc: '特定のルールを適用' },
      'UserAutoTagging::DailyWorker' => { args: '(不要)', desc: '日次オートタグ処理' },
      'UserAutoTagging::EventWorker' => { args: 'user_id, event_type', desc: 'ユーザーイベント処理' },
      'Deliveries::Birthday::SetupWorker' => { args: 'birthday_id, tenant_id', desc: '誕生日配信セットアップ' },
      'Deliveries::ConfirmImportWorker' => { args: 'type, record_id, tenant_id', desc: '配信インポート確認' },
      'Deliveries::ConfirmResultWorker' => { args: 'type, record_id, tenant_id', desc: '配信結果確認' },
      'Deliveries::FixedTime::SetupWorker' => { args: 'schedule_id, tenant_id', desc: '固定時間配信セットアップ' },
      'Deliveries::OrchestratorWorker' => { args: '(不要)', desc: '配信オーケストレーター' },
    }.freeze, T::Hash[String, { args: String, desc: String }],)

    def new
      @allowed_jobs = ALLOWED_JOBS.keys
      @job_hints = JOB_HINTS
    end

    def enqueue
      job_name_str = params[:name].to_s
      job_args = params[:args].to_s.split(',').map(&:strip)

      job_class = ALLOWED_JOBS[job_name_str]

      if job_class.present?
        job_id = job_class.perform_async(*job_args)
        redirect_to new_ruler_area_sidekiq_job_path, notice: "enqueue #{job_name_str} with #{job_args}, id: #{job_id}"
      else
        redirect_to new_ruler_area_sidekiq_job_path, alert: "Job name #{job_name_str} is invalid. Allowed: #{ALLOWED_JOBS.keys.join(', ')}"
      end
    end
  end
end
