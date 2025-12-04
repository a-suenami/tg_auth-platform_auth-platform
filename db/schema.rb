# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 0) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "account_locks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "email", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "lock_expired_at"
    t.datetime "last_failed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "email"], name: "idx_account_locks_tenant_id_email_uniq", unique: true
    t.index ["tenant_id", "unlock_token"], name: "idx_account_locks_tenant_id_unlock_token_uniq", unique: true
    t.index ["tenant_id"], name: "index_account_locks_on_tenant_id"
  end

  create_table "admins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "name"
    t.string "email"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "uid"], name: "idx_admins_tenant_id_uid_uniq", unique: true
    t.index ["tenant_id"], name: "index_admins_on_tenant_id"
  end

  create_table "auto_tagging_schedules", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Time-based schedules for auto-tagging rules", force: :cascade do |t|
    t.citext "tenant_id", null: false, comment: "Tenant reference"
    t.uuid "user_auto_tagging_id", null: false, comment: "Auto-tagging rule reference (1:1)"
    t.datetime "start_at", comment: "Schedule start time (both null or both not null)"
    t.datetime "end_at", comment: "Schedule end time (both null or both not null)"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_auto_tagging_schedules_on_tenant_id"
    t.index ["user_auto_tagging_id"], name: "index_auto_tagging_schedules_on_user_auto_tagging_id", unique: true
  end

  create_table "contact_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.string "zip_code"
    t.integer "prefecture_code"
    t.string "city"
    t.string "street"
    t.string "building"
    t.string "phone_number"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "user_id"], name: "idx_contact_addresses_tenant_id_user_id_uniq", unique: true
    t.index ["tenant_id"], name: "index_contact_addresses_on_tenant_id"
    t.index ["user_id"], name: "index_contact_addresses_on_user_id"
  end

  create_table "deliveries", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Email delivery campaigns", force: :cascade do |t|
    t.citext "tenant_id", null: false, comment: "Tenant reference"
    t.string "name", null: false, comment: "Delivery event name"
    t.uuid "template_id", null: false, comment: "Email template reference"
    t.string "delivery_type", default: "datetime", null: false, comment: "datetime | birthday"
    t.datetime "scheduled_at", comment: "Scheduled delivery datetime (for datetime type)"
    t.integer "birthday_offset_days", default: 0, comment: "Days offset from birthday (for birthday type)"
    t.string "birthday_delivery_time", comment: "Delivery time HH:MM (for birthday type)"
    t.string "status", default: "draft", null: false, comment: "Delivery status"
    t.uuid "created_by_id", comment: "Admin who created"
    t.uuid "updated_by_id", comment: "Admin who last updated"
    t.datetime "published_at", comment: "When delivery was published/scheduled"
    t.uuid "published_by_id", comment: "Admin who published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_deliveries_on_created_by_id"
    t.index ["published_by_id"], name: "index_deliveries_on_published_by_id"
    t.index ["status", "scheduled_at"], name: "index_deliveries_on_status_and_scheduled_at"
    t.index ["template_id"], name: "index_deliveries_on_template_id"
    t.index ["tenant_id", "delivery_type"], name: "index_deliveries_on_tenant_id_and_delivery_type"
    t.index ["tenant_id", "status"], name: "index_deliveries_on_tenant_id_and_status"
    t.index ["tenant_id"], name: "index_deliveries_on_tenant_id"
    t.index ["updated_by_id"], name: "index_deliveries_on_updated_by_id"
  end

  create_table "delivery_activities", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Delivery audit log", force: :cascade do |t|
    t.citext "tenant_id", null: false, comment: "Tenant reference"
    t.uuid "delivery_id", null: false, comment: "Delivery reference"
    t.uuid "admin_id", comment: "Admin who performed action"
    t.string "action", null: false, comment: "Action type"
    t.jsonb "metadata", default: {}, comment: "What changed (JSON)"
    t.text "note", comment: "Optional note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_delivery_activities_on_admin_id"
    t.index ["delivery_id", "created_at"], name: "idx_delivery_activities_timeline"
    t.index ["delivery_id"], name: "index_delivery_activities_on_delivery_id"
    t.index ["tenant_id", "delivery_id"], name: "index_delivery_activities_on_tenant_id_and_delivery_id"
    t.index ["tenant_id"], name: "index_delivery_activities_on_tenant_id"
  end

  create_table "delivery_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.boolean "is_default"
    t.string "zip_code"
    t.integer "prefecture_code"
    t.string "city"
    t.string "street"
    t.string "building"
    t.string "phone_number"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_delivery_addresses_on_tenant_id"
    t.index ["user_id"], name: "index_delivery_addresses_on_user_id"
  end

  create_table "delivery_executions", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Per-user delivery tracking", force: :cascade do |t|
    t.citext "tenant_id", null: false, comment: "Tenant reference"
    t.uuid "delivery_id", null: false, comment: "Delivery reference"
    t.uuid "user_id", null: false, comment: "Target user"
    t.string "status", default: "pending", null: false, comment: "Execution status"
    t.datetime "scheduled_for", comment: "When this execution is scheduled"
    t.datetime "sent_at", comment: "When email was actually sent"
    t.text "error_message", comment: "Error message if failed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_id", "user_id"], name: "idx_delivery_executions_unique", unique: true
    t.index ["delivery_id"], name: "index_delivery_executions_on_delivery_id"
    t.index ["status", "scheduled_for"], name: "idx_delivery_executions_pending"
    t.index ["tenant_id", "delivery_id"], name: "index_delivery_executions_on_tenant_id_and_delivery_id"
    t.index ["tenant_id"], name: "index_delivery_executions_on_tenant_id"
    t.index ["user_id"], name: "index_delivery_executions_on_user_id"
  end

  create_table "delivery_user_tags", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Many-to-many: deliveries to user_tags", force: :cascade do |t|
    t.citext "tenant_id", null: false, comment: "Tenant reference"
    t.uuid "delivery_id", null: false, comment: "Delivery reference"
    t.uuid "user_tag_id", null: false, comment: "User tag reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_id", "user_tag_id"], name: "idx_delivery_user_tags_unique", unique: true
    t.index ["delivery_id"], name: "index_delivery_user_tags_on_delivery_id"
    t.index ["tenant_id", "delivery_id"], name: "index_delivery_user_tags_on_tenant_id_and_delivery_id"
    t.index ["tenant_id"], name: "index_delivery_user_tags_on_tenant_id"
    t.index ["user_tag_id"], name: "index_delivery_user_tags_on_user_tag_id"
  end

  create_table "email_templates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "name", null: false
    t.string "template_type", null: false
    t.string "subject", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "template_type"], name: "index_email_templates_on_tenant_id_template_type", unique: true
    t.index ["tenant_id"], name: "index_email_templates_on_tenant_id"
  end

  create_table "komoju_record_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "remote_id", null: false, comment: "Komoju merchant ID"
    t.string "display_name", null: false, comment: "Account identification name for admin"
    t.string "secret_key_encrypted", null: false, comment: "Encrypted Komoju secret key"
    t.string "webhook_secret_encrypted", null: false, comment: "Encrypted webhook signature secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["remote_id"], name: "idx_komoju_record_accounts_remote_id_uniq", unique: true
    t.index ["tenant_id"], name: "index_komoju_record_accounts_on_tenant_id"
  end

  create_table "komoju_record_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.string "remote_id", null: false, comment: "Komoju payment ID"
    t.string "status", null: false, comment: "authorized/captured/expired/cancelled"
    t.integer "amount", null: false, comment: "Amount in JPY"
    t.string "confirmation_code", comment: "Payment code for user lookup"
    t.datetime "payment_deadline", comment: "Payment expiration (for background jobs)"
    t.datetime "authorized_at", comment: "When payment created"
    t.datetime "captured_at", comment: "When payment completed"
    t.datetime "expired_at", comment: "When payment expired"
    t.jsonb "komoju_data", default: {}, comment: "Full API response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_deadline"], name: "idx_komoju_payments_payment_deadline"
    t.index ["status"], name: "idx_komoju_payments_status"
    t.index ["tenant_id", "remote_id"], name: "idx_komoju_payments_tenant_remote_id_uniq", unique: true
    t.index ["tenant_id"], name: "index_komoju_record_payments_on_tenant_id"
    t.index ["user_id"], name: "index_komoju_record_payments_on_user_id"
  end

  create_table "login_spa_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "name", null: false
    t.string "uid", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "login_url", null: false
    t.string "sign_up_url"
    t.string "redirect_url_on_password_reset", null: false
    t.index ["tenant_id"], name: "index_login_spa_applications_on_tenant_id"
    t.index ["uid"], name: "index_login_spa_applications_on_uid", unique: true
  end

  create_table "membership_contract_terms", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "ユーザーのメンバーシップ契約の詳細,変更履歴", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.uuid "membership_contract_id", null: false
    t.uuid "membership_plan_id", null: false
    t.string "payment_type", null: false, comment: "支払い方法: credit_card, convenience, campaign_code, external_linkageなど"
    t.string "status", null: false, comment: "ステータス"
    t.datetime "start_at", comment: "開始日時"
    t.datetime "end_at", comment: "終了日時"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_contract_id"], name: "index_membership_contract_terms_on_membership_contract_id"
    t.index ["membership_plan_id"], name: "index_membership_contract_terms_on_membership_plan_id"
    t.index ["tenant_id"], name: "index_membership_contract_terms_on_tenant_id"
    t.index ["user_id"], name: "index_membership_contract_terms_on_user_id"
  end

  create_table "membership_contracts", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "ユーザーのメンバーシップ契約", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.datetime "expired_at", comment: "失効日時"
    t.boolean "cancel_at_period_end", default: false, comment: "次回更新時に解約フラグ"
    t.string "status", default: "active", null: false, comment: "ステータス"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expired_at"], name: "idx_membership_contracts_expired_at"
    t.index ["tenant_id"], name: "index_membership_contracts_on_tenant_id"
    t.index ["user_id"], name: "index_membership_contracts_on_user_id"
  end

  create_table "membership_groups", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "メンバーシップグループ（段階的プラン用）", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "name", null: false, comment: "グループ名（英数字のみ）"
    t.string "display_name", null: false, comment: "表示名"
    t.integer "position", default: 0, comment: "表示順序（段階の順番）"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "name"], name: "idx_membership_groups_tenant_id_name_uniq", unique: true
    t.index ["tenant_id", "position"], name: "idx_membership_groups_tenant_position"
    t.index ["tenant_id"], name: "index_membership_groups_on_tenant_id"
  end

  create_table "membership_plan_components", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "メンバーシッププランの構成要素（バンドルプラン用）", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "membership_plan_id", null: false
    t.uuid "membership_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_id"], name: "index_membership_plan_components_on_membership_id"
    t.index ["membership_plan_id", "membership_id"], name: "idx_membership_plan_components_plan_membership_uniq", unique: true
    t.index ["membership_plan_id"], name: "index_membership_plan_components_on_membership_plan_id"
    t.index ["tenant_id"], name: "index_membership_plan_components_on_tenant_id"
  end

  create_table "membership_plan_payment_method_mappings", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "メンバーシッププランの支払い方法のマッピング", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "membership_plan_id", null: false
    t.uuid "membership_plan_payment_method_id", null: false
    t.uuid "priceable_id", comment: "Priceオブジェクト"
    t.string "priceable_type"
    t.integer "amount", null: false, comment: "金額"
    t.string "currency", null: false, comment: "通貨"
    t.boolean "is_active", default: true, comment: "有効フラグ"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_plan_id"], name: "idx_on_membership_plan_id_abf7e120d7"
    t.index ["membership_plan_payment_method_id"], name: "idx_on_membership_plan_payment_method_id_45519b8566"
    t.index ["priceable_type", "priceable_id"], name: "idx_on_priceable_type_priceable_id_bc1644aaac"
    t.index ["tenant_id"], name: "index_membership_plan_payment_method_mappings_on_tenant_id"
  end

  create_table "membership_plan_payment_methods", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "メンバーシッププランの支払い方法", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "membership_plan_id", null: false
    t.string "payment_type", null: false, comment: "支払い方法: credit_card, convenience, campaign_code, external_linkage"
    t.boolean "is_active", default: true, comment: "有効フラグ"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_plan_id", "payment_type"], name: "idx_membership_plan_payment_methods_plan_type_uniq", unique: true
    t.index ["membership_plan_id"], name: "index_membership_plan_payment_methods_on_membership_plan_id"
    t.index ["tenant_id"], name: "index_membership_plan_payment_methods_on_tenant_id"
  end

  create_table "membership_plans", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "メンバーシップの契約プラン", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "name", null: false, comment: "プラン名"
    t.boolean "recurrence", default: false, null: false, comment: "定期課金フラグ: true=サブスクリプション, false=買い切り"
    t.integer "recurring_interval_count", default: 1, null: false, comment: "更新サイクルの数(1=1日/週/月/年, 2=2日/週/月/年)"
    t.string "recurring_interval_unit", default: "month", null: false, comment: "更新サイクルの単位 (day/week/month/year)"
    t.integer "amount", null: false, comment: "請求金額"
    t.boolean "is_active", default: true, comment: "有効フラグ"
    t.datetime "enabled_at", comment: "有効化日時"
    t.datetime "disabled_at", comment: "無効化日時"
    t.integer "trial_period_days", default: 0, null: false, comment: "トライアル期間"
    t.string "billing_anchor", default: "by_start_day", null: false, comment: "締めの基準: by_start_day(登録日基準), by_fixed_month_day(毎月の特定日)"
    t.integer "anchor_day_of_month", comment: "fixed_month_day時の締め日(1-31 月末指定時は31)。by_fixed_month_day時のみ使用"
    t.integer "position", default: 0, null: false, comment: "表示順序"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_membership_plans_on_tenant_id"
  end

  create_table "membership_users", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "メンバーシップとUserの中間テーブル", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.uuid "membership_id", null: false
    t.uuid "membership_group_id", comment: "段階的プランの場合のグループ"
    t.uuid "membership_contract_id", comment: "メンバーシップ契約"
    t.datetime "activated_at", comment: "メンバーシップ有効化日時"
    t.datetime "expired_at", comment: "メンバーシップの失効日時"
    t.string "status", comment: "メンバーシップのステータス"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_contract_id"], name: "index_membership_users_on_membership_contract_id"
    t.index ["membership_group_id"], name: "index_membership_users_on_membership_group_id"
    t.index ["membership_id"], name: "index_membership_users_on_membership_id"
    t.index ["tenant_id", "user_id", "membership_id"], name: "idx_membership_users_tenant_user_membership_uniq", unique: true
    t.index ["tenant_id"], name: "index_membership_users_on_tenant_id"
    t.index ["user_id"], name: "index_membership_users_on_user_id"
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "メンバーシップ", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "membership_group_id", comment: "メンバーシップグループ"
    t.string "name", comment: "メンバーシップ識別子"
    t.string "display_name", comment: "メンバーシップ名称"
    t.integer "position", comment: "表示順序"
    t.integer "tier", comment: "階級"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_group_id"], name: "index_memberships_on_membership_group_id"
    t.index ["tenant_id"], name: "index_memberships_on_tenant_id"
  end

  create_table "oauth_access_grants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "resource_owner_id", null: false
    t.uuid "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.string "code_challenge"
    t.string "code_challenge_method"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["tenant_id"], name: "index_oauth_access_grants_on_tenant_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "resource_owner_id"
    t.uuid "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["tenant_id"], name: "index_oauth_access_tokens_on_tenant_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enable_client_credential_flow", default: false
    t.boolean "enable_push_event", default: false
    t.boolean "require_sms_mfa", default: false
    t.text "allowed_logout_urls"
    t.index ["tenant_id"], name: "index_oauth_applications_on_tenant_id"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "oauth_openid_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "access_grant_id", null: false
    t.string "nonce", null: false
    t.index ["access_grant_id"], name: "index_oauth_openid_requests_on_access_grant_id"
  end

  create_table "payment_subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "支払い取引情報", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.uuid "membership_contract_id", null: false, comment: "メンバーシップ契約ID"
    t.uuid "subscribable_id", comment: "サブスクリプションオブジェクト"
    t.string "subscribable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_contract_id"], name: "index_payment_subscriptions_on_membership_contract_id"
    t.index ["subscribable_type", "subscribable_id"], name: "idx_on_subscribable_type_subscribable_id_023c9144d9"
    t.index ["tenant_id", "user_id"], name: "idx_payment_subscriptions_tenant_user"
    t.index ["tenant_id"], name: "index_payment_subscriptions_on_tenant_id"
    t.index ["user_id"], name: "index_payment_subscriptions_on_user_id"
  end

  create_table "payment_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "支払い取引情報", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.uuid "membership_contract_id", null: false, comment: "メンバーシップ契約ID"
    t.string "payment_type", null: false, comment: "支払い方法: credit_card, convenience, campaign_code, external_linkage"
    t.string "payment_provider", comment: "決済プロバイダ: stripe, komojuなど"
    t.datetime "activated_at", comment: "有効化日時"
    t.datetime "expired_at", comment: "失効日時"
    t.string "status", null: false, comment: "ステータス"
    t.boolean "recurrence", default: false, null: false, comment: "定期課金フラグ: true=サブスクリプション, false=買い切り"
    t.integer "paid_amount", default: 0, null: false, comment: "支払い済み金額"
    t.uuid "chargeable_id", comment: "決済情報"
    t.string "chargeable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chargeable_type", "chargeable_id"], name: "idx_on_chargeable_type_chargeable_id_c87a4bad66"
    t.index ["expired_at"], name: "idx_payment_transactions_expired_at"
    t.index ["membership_contract_id"], name: "index_payment_transactions_on_membership_contract_id"
    t.index ["tenant_id", "user_id"], name: "idx_payment_transactions_tenant_user"
    t.index ["tenant_id"], name: "index_payment_transactions_on_tenant_id"
    t.index ["user_id"], name: "index_payment_transactions_on_user_id"
  end

  create_table "rulers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "idx_rulers_uid_uniq", unique: true
  end

  create_table "shopify_record__customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "multipass_store_id"
    t.citext "store_name"
    t.uuid "user_id", null: false
    t.string "remote_id", null: false
    t.citext "email", null: false
    t.string "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["multipass_store_id"], name: "index_shopify_record__customers_on_multipass_store_id"
    t.index ["store_name", "email"], name: "idx_shopify_record__customers_store_name_email_uniq", unique: true
    t.index ["tenant_id"], name: "index_shopify_record__customers_on_tenant_id"
    t.index ["user_id"], name: "index_shopify_record__customers_on_user_id"
  end

  create_table "shopify_record__multipass_stores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "store_url"
    t.citext "store_name"
    t.string "api_key"
    t.string "oauth_client_id"
    t.string "scopes"
    t.string "multipass_secret"
    t.string "webhook_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_shopify_record__multipass_stores_on_tenant_id"
  end

  create_table "stripe_record_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "remote_id", null: false, comment: "Stripe のアカウント ID"
    t.citext "tenant_id", null: false
    t.uuid "api_key_id"
    t.uuid "controlling_platform_id"
    t.string "type"
    t.string "business_profile_name"
    t.string "payments_statement_descriptor"
    t.string "payments_statement_descriptor_kana"
    t.string "payments_statement_descriptor_kanji"
    t.string "display_name", null: false, comment: "API キーがどのアカウントのものかを識別するための名前"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_key_id"], name: "index_stripe_record_accounts_on_api_key_id"
    t.index ["controlling_platform_id"], name: "index_stripe_record_accounts_on_controlling_platform_id"
    t.index ["remote_id", "controlling_platform_id"], name: "index_stripe_record_accounts_remote_id_unique", unique: true, nulls_not_distinct: true
    t.index ["tenant_id"], name: "index_stripe_record_accounts_on_tenant_id"
  end

  create_table "stripe_record_api_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "remote_id", null: false, comment: "Stripe の API キー ID"
    t.string "display_name", null: false, comment: "API キーがどのアカウントのものかを識別するための名前"
    t.string "publishable_key", null: false
    t.string "secret_key_encrypted", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["remote_id"], name: "idx_stripe_record_api_keys_remote_id_uniq", unique: true
    t.index ["tenant_id"], name: "index_stripe_record_api_keys_on_tenant_id"
  end

  create_table "stripe_record_charges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "remote_id", null: false, comment: "Stripe の charge ID"
    t.uuid "payment_intent_id", null: false
    t.uuid "user_id", null: false
    t.integer "amount"
    t.integer "amount_captured"
    t.integer "amount_refunded"
    t.string "application_id"
    t.string "application_fee_id"
    t.integer "application_fee_amount"
    t.string "balance_transaction_id"
    t.jsonb "billing_details"
    t.string "calculated_statement_descriptor"
    t.boolean "captured"
    t.string "currency"
    t.string "customer_id"
    t.string "description"
    t.string "destination"
    t.jsonb "dispute"
    t.boolean "disputed"
    t.string "failure_balance_transaction_id"
    t.string "failure_code"
    t.string "failure_message"
    t.jsonb "fraud_details"
    t.string "invoice_id"
    t.boolean "livemode"
    t.jsonb "metadata"
    t.string "on_behalf_of_id"
    t.string "order"
    t.jsonb "outcome"
    t.boolean "paid"
    t.string "payment_method"
    t.jsonb "payment_method_details"
    t.jsonb "radar_options"
    t.string "receipt_email"
    t.string "receipt_number"
    t.string "receipt_url"
    t.boolean "refunded"
    t.string "review_id"
    t.jsonb "shipping"
    t.string "source"
    t.string "source_transfer_id"
    t.string "statement_descriptor"
    t.string "statement_descriptor_suffix"
    t.string "status"
    t.string "transfer_id"
    t.jsonb "transfer_data"
    t.string "transfer_group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created"
    t.uuid "api_key_account_id", null: false, comment: "API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。"
    t.uuid "connect_account_id", comment: "Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。"
    t.string "charge_type", comment: "Connect のときだけ使用する。どの支払いタイプなのかを表す"
    t.index ["api_key_account_id"], name: "index_stripe_record_charges_on_api_key_account_id"
    t.index ["connect_account_id"], name: "index_stripe_record_charges_on_connect_account_id"
    t.index ["payment_intent_id"], name: "index_stripe_record_charges_on_payment_intent_id"
    t.index ["remote_id"], name: "idx_stripe_record_charge_remote_id_uniq", unique: true
    t.index ["tenant_id"], name: "index_stripe_record_charges_on_tenant_id"
    t.index ["user_id"], name: "index_stripe_record_charges_on_user_id"
  end

  create_table "stripe_record_invoices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "remote_id", null: false, comment: "Stripe の invoices ID"
    t.uuid "user_id", null: false
    t.uuid "payment_source_id", comment: "subscription or charge"
    t.string "payment_source_type"
    t.string "status", default: "draft", null: false, comment: "draft, open, paid, uncollectible, or void"
    t.string "confirmation_secret", comment: "confirmation_secret payment_intent.secret"
    t.string "confirmation_secret_type", comment: "基本的にはpayment_intentのみ"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_source_type", "payment_source_id"], name: "idx_on_payment_source_type_payment_source_id_3bc82c7377"
    t.index ["remote_id"], name: "idx_stripe_record_invoices_remote_id_uniq", unique: true
    t.index ["tenant_id", "remote_id"], name: "index_stripe_record_invoices_on_tenant_and_remote_id", unique: true
    t.index ["tenant_id"], name: "index_stripe_record_invoices_on_tenant_id"
    t.index ["user_id"], name: "index_stripe_record_invoices_on_user_id"
  end

  create_table "stripe_record_payment_intents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "remote_id", null: false, comment: "Stripe の payment intent ID"
    t.uuid "user_id", null: false
    t.uuid "invoice_id"
    t.uuid "chargeable_id", comment: "subscription or charge"
    t.string "chargeable_type"
    t.uuid "latest_charge_id", comment: "latest charge"
    t.string "currency"
    t.integer "amount"
    t.string "status"
    t.string "customer_id"
    t.string "client_secret"
    t.string "confirmation_method"
    t.string "capture_method"
    t.string "payment_method_id"
    t.jsonb "payment_method_configuration_details"
    t.jsonb "payment_method_options"
    t.string "cancellation_reason"
    t.string "description"
    t.jsonb "metadata"
    t.jsonb "next_action"
    t.string "on_behalf_of_id"
    t.integer "application_fee_amount"
    t.jsonb "transfer_data"
    t.string "transfer_group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created"
    t.datetime "canceled_at"
    t.uuid "api_key_account_id", null: false, comment: "API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。"
    t.uuid "connect_account_id", comment: "Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。"
    t.string "charge_type", comment: "Connect のときだけ使用する。どの支払いタイプなのかを表す"
    t.index ["api_key_account_id"], name: "index_stripe_record_payment_intents_on_api_key_account_id"
    t.index ["chargeable_type", "chargeable_id"], name: "idx_on_chargeable_type_chargeable_id_b73c319e28"
    t.index ["connect_account_id"], name: "index_stripe_record_payment_intents_on_connect_account_id"
    t.index ["invoice_id"], name: "index_stripe_record_payment_intents_on_invoice_id"
    t.index ["latest_charge_id"], name: "index_stripe_record_payment_intents_on_latest_charge_id"
    t.index ["remote_id"], name: "idx_stripe_record_payment_intent_remote_id_uniq", unique: true
    t.index ["tenant_id", "remote_id"], name: "index_stripe_record_payment_intents_on_tenant_and_remote_id", unique: true
    t.index ["tenant_id"], name: "index_stripe_record_payment_intents_on_tenant_id"
    t.index ["user_id"], name: "index_stripe_record_payment_intents_on_user_id"
  end

  create_table "stripe_record_payment_methods", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "remote_id", null: false, comment: "Stripe の payment method ID"
    t.uuid "user_id", null: false
    t.uuid "setup_intent_id"
    t.string "type", null: false, comment: "payment method の種類。card など"
    t.jsonb "billing_details", default: {}, comment: "請求先情報"
    t.jsonb "card", default: {}, comment: "card の詳細情報"
    t.string "customer_id", null: false, comment: "この PaymentMethod の持ち主の customer ID"
    t.datetime "detached_at", comment: "detach された日時"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "api_key_account_id", null: false, comment: "API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。"
    t.uuid "connect_account_id", comment: "Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。"
    t.string "charge_type", comment: "Connect のときだけ使用する。どの支払いタイプなのかを表す"
    t.index ["api_key_account_id"], name: "index_stripe_record_payment_methods_on_api_key_account_id"
    t.index ["connect_account_id"], name: "index_stripe_record_payment_methods_on_connect_account_id"
    t.index ["remote_id"], name: "idx_stripe_record_payment_methods_remote_id_uniq", unique: true
    t.index ["setup_intent_id"], name: "index_stripe_record_payment_methods_on_setup_intent_id"
    t.index ["tenant_id"], name: "index_stripe_record_payment_methods_on_tenant_id"
    t.index ["user_id"], name: "index_stripe_record_payment_methods_on_user_id"
  end

  create_table "stripe_record_prices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "product_id", null: false
    t.string "remote_id"
    t.string "name"
    t.integer "amount"
    t.string "interval"
    t.integer "interval_count"
    t.integer "trial_period_days"
    t.boolean "deleted", default: false, null: false
    t.integer "position", default: 1000
    t.boolean "displayed", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_stripe_record_prices_on_product_id"
    t.index ["tenant_id"], name: "index_stripe_record_prices_on_tenant_id"
  end

  create_table "stripe_record_products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "remote_id"
    t.string "name"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_stripe_record_products_on_tenant_id"
  end

  create_table "stripe_record_refunds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "remote_id", null: false, comment: "Stripe の refund ID"
    t.uuid "user_id", null: false
    t.uuid "payment_intent_id", null: false
    t.integer "amount"
    t.string "balance_transaction_id"
    t.string "currency"
    t.jsonb "destination_details"
    t.jsonb "metadata"
    t.string "reason"
    t.string "receipt_number"
    t.string "source_transfer_reversal_id"
    t.string "status"
    t.string "transfer_reversal_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created"
    t.uuid "api_key_account_id", null: false, comment: "API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。"
    t.uuid "connect_account_id", comment: "Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。"
    t.string "charge_type", comment: "Connect のときだけ使用する。どの支払いタイプなのかを表す"
    t.index ["api_key_account_id"], name: "index_stripe_record_refunds_on_api_key_account_id"
    t.index ["connect_account_id"], name: "index_stripe_record_refunds_on_connect_account_id"
    t.index ["payment_intent_id"], name: "index_stripe_record_refunds_on_payment_intent_id"
    t.index ["remote_id"], name: "idx_stripe_record_refund_remote_id_uniq", unique: true
    t.index ["tenant_id"], name: "index_stripe_record_refunds_on_tenant_id"
    t.index ["user_id"], name: "index_stripe_record_refunds_on_user_id"
  end

  create_table "stripe_record_setup_intents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "remote_id", null: false, comment: "Stripe の setup intent ID"
    t.uuid "user_id", null: false
    t.string "client_secret", null: false
    t.string "customer_id"
    t.string "on_behalf_of_id"
    t.string "payment_method_id"
    t.string "status"
    t.string "usage"
    t.datetime "activated_at", comment: "このカードが有効になった日時。NULL だがカードの登録自体には成功している場合、この SetupIntent で登録されたカードは定期的に削除する。"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "api_key_account_id", null: false, comment: "API Key を持っているアカウント。通常の決済であればその決済のアカウントとなる。Connect の場合はプラットフォームアカウントになる。"
    t.uuid "connect_account_id", comment: "Connect のときだけ使用する。この決済がどの Connected アカウントに対する支払いなのかを表す。"
    t.string "charge_type", comment: "Connect のときだけ使用する。どの支払いタイプなのかを表す"
    t.index ["api_key_account_id"], name: "index_stripe_record_setup_intents_on_api_key_account_id"
    t.index ["connect_account_id"], name: "index_stripe_record_setup_intents_on_connect_account_id"
    t.index ["remote_id"], name: "idx_stripe_record_setup_intents_remote_id_uniq", unique: true
    t.index ["tenant_id"], name: "index_stripe_record_setup_intents_on_tenant_id"
    t.index ["user_id"], name: "index_stripe_record_setup_intents_on_user_id"
  end

  create_table "stripe_record_subscription_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "subscription_id", null: false
    t.uuid "price_id", null: false
    t.string "remote_id", null: false
    t.integer "quantity", default: 1
    t.jsonb "billing_thresholds"
    t.integer "current_period_start"
    t.integer "current_period_end"
    t.jsonb "discounts", default: []
    t.jsonb "metadata", default: {}
    t.jsonb "tax_rates", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["price_id"], name: "index_stripe_record_subscription_items_on_price_id"
    t.index ["remote_id"], name: "index_stripe_record_subscription_items_on_remote_id", unique: true
    t.index ["subscription_id", "price_id"], name: "index_stripe_record_si_on_subscription_and_price", unique: true
    t.index ["subscription_id"], name: "index_stripe_record_subscription_items_on_subscription_id"
    t.index ["tenant_id"], name: "index_stripe_record_subscription_items_on_tenant_id"
  end

  create_table "stripe_record_subscription_schedules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.uuid "subscription_id", null: false
    t.string "remote_id", null: false
    t.string "remote_customer"
    t.string "status"
    t.jsonb "phases"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_stripe_record_subscription_schedules_on_subscription_id"
    t.index ["tenant_id"], name: "index_stripe_record_subscription_schedules_on_tenant_id"
    t.index ["user_id"], name: "index_stripe_record_subscription_schedules_on_user_id"
  end

  create_table "stripe_record_subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.uuid "product_id", null: false
    t.uuid "price_id", null: false
    t.uuid "pending_setup_intent_id"
    t.integer "amount", default: 0
    t.integer "tax", default: 0
    t.string "currency", default: "JPY"
    t.boolean "refunded", default: false
    t.string "refund_reason"
    t.datetime "current_period_start", comment: "現在の請求期間の開始日時"
    t.datetime "current_period_end", comment: "現在の請求期間の終了日時"
    t.integer "trial_period_days", comment: "トライアル日数"
    t.datetime "trial_end", comment: "トライアル終了日時"
    t.datetime "trial_start", comment: "トライアル開始日時"
    t.string "remote_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pending_setup_intent_id"], name: "index_stripe_record_subscriptions_on_pending_setup_intent_id"
    t.index ["price_id"], name: "index_stripe_record_subscriptions_on_price_id"
    t.index ["product_id"], name: "index_stripe_record_subscriptions_on_product_id"
    t.index ["tenant_id"], name: "index_stripe_record_subscriptions_on_tenant_id"
    t.index ["user_id"], name: "index_stripe_record_subscriptions_on_user_id"
  end

  create_table "stripe_record_trial_histories", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Stripeのトライアル履歴", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.uuid "membership_id", null: false
    t.uuid "membership_plan_id", null: false
    t.uuid "stripe_record_subscription_id"
    t.string "fingerprint", null: false, comment: "決済手段のユニークな識別子(ex: クレジットカードのfingerprint)"
    t.datetime "trial_start", null: false, comment: "トライアル開始日時"
    t.datetime "trial_end", comment: "トライアル終了日時"
    t.integer "trial_period_days", null: false, comment: "トライアル日数"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_id"], name: "index_stripe_record_trial_histories_on_membership_id"
    t.index ["membership_plan_id"], name: "index_stripe_record_trial_histories_on_membership_plan_id"
    t.index ["stripe_record_subscription_id"], name: "idx_on_stripe_record_subscription_id_95f8fd9518"
    t.index ["tenant_id", "membership_id", "fingerprint"], name: "idx_stripe_record_trial_histories_unique", unique: true
    t.index ["tenant_id"], name: "index_stripe_record_trial_histories_on_tenant_id"
    t.index ["user_id"], name: "index_stripe_record_trial_histories_on_user_id"
  end

  create_table "template_mail_histories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "template_id", null: false, comment: "Parent template"
    t.uuid "version_id", comment: "Mail template version (nullable)"
    t.string "event_type", null: false, comment: "Event type: published, scheduled, rescheduled, draft_created, draft_updated"
    t.jsonb "payload", default: {}, null: false, comment: "Event metadata"
    t.uuid "actor_id", comment: "Admin who performed action"
    t.datetime "created_at", null: false
    t.index ["actor_id"], name: "index_template_mail_histories_on_actor_id"
    t.index ["created_at"], name: "idx_template_mail_histories_created_at"
    t.index ["event_type"], name: "idx_template_mail_histories_event_type"
    t.index ["template_id", "created_at"], name: "idx_template_mail_histories_template_created"
    t.index ["template_id"], name: "index_template_mail_histories_on_template_id"
    t.index ["tenant_id"], name: "index_template_mail_histories_on_tenant_id"
    t.index ["version_id"], name: "index_template_mail_histories_on_version_id"
  end

  create_table "template_mail_versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "template_id", null: false, comment: "Parent template"
    t.integer "version", null: false, comment: "バージョン番号"
    t.string "title", null: false, comment: "メールタイトル（スナップショット）"
    t.text "body", null: false, comment: "メール本文（スナップショット）"
    t.datetime "public_started_at", null: false, comment: "公開開始日時"
    t.uuid "published_by_id", comment: "公開者（Admin）"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["public_started_at"], name: "idx_template_mail_versions_public_started_at"
    t.index ["published_by_id"], name: "index_template_mail_versions_on_published_by_id"
    t.index ["template_id", "version"], name: "idx_template_mail_versions_template_version", unique: true
    t.index ["template_id"], name: "index_template_mail_versions_on_template_id"
    t.index ["tenant_id"], name: "index_template_mail_versions_on_tenant_id"
  end

  create_table "template_mails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "template_id", null: false, comment: "Parent template"
    t.string "title", comment: "メールタイトル（現在の下書き）"
    t.text "body", comment: "メール本文（現在の下書き）"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id"], name: "idx_template_mails_template_id", unique: true
    t.index ["tenant_id"], name: "index_template_mails_on_tenant_id"
  end

  create_table "templates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "name", null: false, comment: "テンプレート名"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "name"], name: "idx_templates_tenant_name"
    t.index ["tenant_id"], name: "index_templates_on_tenant_id"
  end

  create_table "tenant_komoju_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "komoju_account_id", null: false
    t.boolean "enabled", default: true, null: false, comment: "Whether Komoju payment is enabled for this tenant"
    t.integer "default_expiry_days", default: 7, null: false, comment: "Default payment expiration in days for konbini"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["komoju_account_id"], name: "index_tenant_komoju_accounts_on_komoju_account_id"
    t.index ["tenant_id", "komoju_account_id"], name: "index_komoju_account_per_tenant_unique", unique: true
    t.index ["tenant_id"], name: "index_tenant_komoju_accounts_on_tenant_id", unique: true
  end

  create_table "tenant_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "google_cloud_service_account"
    t.string "google_cloud_project_id"
    t.string "recaptcha_enterprise_checkbox_site_key"
    t.string "recaptcha_enterprise_score_based_site_key"
    t.string "twilio_verify_service_sid"
    t.jsonb "profile_field_rules", default: {}
    t.string "sender_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "idx_tenant_settings_tenant_id_uniq", unique: true
    t.index ["tenant_id"], name: "index_tenant_settings_on_tenant_id"
  end

  create_table "tenant_stripe_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "stripe_account_id", null: false
    t.string "charge_type", comment: "Connect の場合にどの支払いタイプを利用するか"
    t.decimal "fee_rate", precision: 6, scale: 5, comment: "手数料率（100% ~ 0.001%）。stripe_account.controlling_platform がいる場合のみ（Connect）利用する。"
    t.string "tax_rate_id", comment: "stripe の税率ID"
    t.string "webhook_secret", comment: "Stripe webhookの署名検証用シークレット"
    t.integer "membership_grace_period_minutes", default: 60, null: false, comment: "メンバーシップの有効期限の猶予期間（分）"
    t.boolean "send_subscription_update_succeeded_email_for_all_intervals", default: false, null: false, comment: "すべてのインターバルでサブスクリプション更新成功メールを送信するかどうか"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_account_id"], name: "index_tenant_stripe_accounts_on_stripe_account_id"
    t.index ["tenant_id", "stripe_account_id"], name: "index_stripe_account_per_tenant_unique", unique: true
    t.index ["tenant_id"], name: "index_tenant_stripe_accounts_on_tenant_id", unique: true
  end

  create_table "tenants", id: :citext, force: :cascade do |t|
    t.string "name"
    t.string "domain"
    t.boolean "sms_verification_required", default: false
    t.string "card_payment_gateway", comment: "カード決済で使用するペイメントゲートウェイ"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_auto_tagging_rule_blocks", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Rule blocks (OR logic between blocks)", force: :cascade do |t|
    t.citext "tenant_id", null: false, comment: "Tenant reference"
    t.uuid "user_auto_tagging_id", null: false, comment: "Auto-tagging rule reference"
    t.integer "position", null: false, comment: "Display order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_user_auto_tagging_rule_blocks_on_tenant_id"
    t.index ["user_auto_tagging_id", "position"], name: "idx_on_user_auto_tagging_id_position_b71f663284"
    t.index ["user_auto_tagging_id"], name: "index_user_auto_tagging_rule_blocks_on_user_auto_tagging_id"
  end

  create_table "user_auto_tagging_rules", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Individual rules within blocks (AND logic within block)", force: :cascade do |t|
    t.citext "tenant_id", null: false, comment: "Tenant reference"
    t.uuid "rule_block_id", null: false, comment: "Rule block reference"
    t.string "condition_type", null: false, comment: "Type: membership, plan, prefecture, gender, age, account_link"
    t.jsonb "config", default: {}, null: false, comment: "Condition configuration (varies by type)"
    t.integer "position", null: false, comment: "Display order within block"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["condition_type"], name: "index_user_auto_tagging_rules_on_condition_type"
    t.index ["rule_block_id", "position"], name: "index_user_auto_tagging_rules_on_rule_block_id_and_position"
    t.index ["rule_block_id"], name: "index_user_auto_tagging_rules_on_rule_block_id"
    t.index ["tenant_id"], name: "index_user_auto_tagging_rules_on_tenant_id"
  end

  create_table "user_auto_tagging_tags", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Tags assigned by auto-tagging rules", force: :cascade do |t|
    t.citext "tenant_id", null: false, comment: "Tenant reference"
    t.uuid "user_auto_tagging_id", null: false, comment: "Auto-tagging rule reference"
    t.uuid "user_tag_id", null: false, comment: "Tag to assign"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_user_auto_tagging_tags_on_tenant_id"
    t.index ["user_auto_tagging_id", "user_tag_id"], name: "idx_auto_tagging_tags_unique", unique: true
    t.index ["user_auto_tagging_id"], name: "index_user_auto_tagging_tags_on_user_auto_tagging_id"
    t.index ["user_tag_id"], name: "index_user_auto_tagging_tags_on_user_tag_id"
  end

  create_table "user_auto_taggings", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Auto-tagging rules for users", force: :cascade do |t|
    t.citext "tenant_id", null: false, comment: "Tenant reference"
    t.string "name", null: false, comment: "Rule name (CMS display)"
    t.text "description", comment: "Rule description"
    t.boolean "enabled", default: true, null: false, comment: "Whether rule is active"
    t.boolean "shareable", default: false, null: false, comment: "Tag shareable with linked apps (連携タグ設定)"
    t.uuid "created_by_id", comment: "Admin who created this rule"
    t.uuid "updated_by_id", comment: "Admin who last updated this rule"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_user_auto_taggings_on_created_by_id"
    t.index ["enabled"], name: "index_user_auto_taggings_on_enabled"
    t.index ["tenant_id", "name"], name: "index_user_auto_taggings_on_tenant_id_and_name", unique: true
    t.index ["tenant_id"], name: "index_user_auto_taggings_on_tenant_id"
    t.index ["updated_by_id"], name: "index_user_auto_taggings_on_updated_by_id"
  end

  create_table "user_events", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "ユーザーイベント履歴", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.datetime "transaction_time", null: false, comment: "イベント発生日時"
    t.string "event_type", null: false, comment: "イベント種別: created, manually_tagged, auto_tagged など"
    t.jsonb "payload", default: {}, null: false, comment: "イベント詳細データ"
    t.datetime "created_at", null: false
    t.index ["tenant_id", "transaction_time"], name: "idx_user_events_tenant_time"
    t.index ["tenant_id", "user_id", "transaction_time"], name: "idx_user_events_tenant_user_time"
    t.index ["tenant_id"], name: "index_user_events_on_tenant_id"
    t.index ["user_id"], name: "index_user_events_on_user_id"
  end

  create_table "user_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "first_name_kana"
    t.string "last_name_kana"
    t.date "birth_date"
    t.string "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "user_id"], name: "idx_user_profiles_tenant_id_user_id_uniq", unique: true
    t.index ["tenant_id"], name: "index_user_profiles_on_tenant_id"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "user_tag_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "User tag assignments (manual and auto)", force: :cascade do |t|
    t.citext "tenant_id", null: false, comment: "Tenant reference"
    t.uuid "user_id", null: false, comment: "User being tagged"
    t.uuid "user_tag_id", null: false, comment: "Tag being assigned"
    t.string "assignment_type", null: false, comment: "Type: manual or auto"
    t.uuid "assigned_by_id", comment: "Admin who manually assigned (for manual only)"
    t.uuid "user_auto_tagging_id", comment: "Auto-tagging rule that assigned (for auto only)"
    t.datetime "assigned_at", null: false, comment: "When tag was assigned"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_by_id"], name: "index_user_tag_assignments_on_assigned_by_id"
    t.index ["assignment_type"], name: "index_user_tag_assignments_on_assignment_type"
    t.index ["tenant_id", "user_id", "user_tag_id"], name: "index_user_tag_assignments_unique", unique: true
    t.index ["tenant_id"], name: "index_user_tag_assignments_on_tenant_id"
    t.index ["user_auto_tagging_id"], name: "index_user_tag_assignments_on_user_auto_tagging_id"
    t.index ["user_id"], name: "index_user_tag_assignments_on_user_id"
    t.index ["user_tag_id"], name: "index_user_tag_assignments_on_user_tag_id"
  end

  create_table "user_tags", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "User tags for manual tagging", force: :cascade do |t|
    t.citext "tenant_id", null: false, comment: "Tenant reference"
    t.string "name", null: false, comment: "Tag name"
    t.text "description", comment: "Tag description"
    t.uuid "created_by_id", comment: "Admin who created this tag"
    t.uuid "updated_by_id", comment: "Admin who last updated this tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_user_tags_on_created_by_id"
    t.index ["tenant_id", "name"], name: "index_user_tags_on_tenant_id_and_name", unique: true
    t.index ["tenant_id"], name: "index_user_tags_on_tenant_id"
    t.index ["updated_by_id"], name: "index_user_tags_on_updated_by_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "email"
    t.string "password_digest"
    t.boolean "enabled", default: false
    t.string "phone_number"
    t.boolean "sms_verified", default: false
    t.boolean "email_verified", default: false
    t.boolean "suppress_sms_verification", default: false
    t.boolean "deleted", default: false
    t.datetime "deleted_at"
    t.string "password_reset_code"
    t.float "captcha_score"
    t.string "payment_provider"
    t.string "payment_customer_id"
    t.string "default_payment_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "email"], name: "index_users_on_tenant_id_email", unique: true, where: "(deleted_at IS NULL)"
    t.index ["tenant_id", "id"], name: "index_users_on_tenant_id_and_id", unique: true
    t.index ["tenant_id", "phone_number"], name: "index_users_on_tenant_id_phone_number", unique: true, where: "(deleted_at IS NULL)"
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  create_table "users__email_verifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.string "code", null: false
    t.datetime "expired_at", null: false
    t.integer "remaining_attempts", default: 0
    t.string "verifier_type", default: "registration", null: false
    t.string "email"
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_users__email_verifiers_on_tenant_id"
    t.index ["user_id"], name: "index_users__email_verifiers_on_user_id"
  end

  create_table "users__linked_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.uuid "oauth_application_id", null: false
    t.string "scopes", null: false
    t.datetime "last_linked_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["oauth_application_id"], name: "index_users__linked_applications_on_oauth_application_id"
    t.index ["tenant_id", "user_id", "oauth_application_id"], name: "idx_linked_applications_tenant_user_oauth_application_uniq", unique: true
    t.index ["tenant_id"], name: "index_users__linked_applications_on_tenant_id"
    t.index ["user_id"], name: "index_users__linked_applications_on_user_id"
  end

  create_table "users__password_resets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.string "code", null: false
    t.datetime "expired_at", null: false
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_users__password_resets_on_tenant_id"
    t.index ["user_id"], name: "index_users__password_resets_on_user_id"
  end

  create_table "users__sms_verifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.string "code", null: false
    t.datetime "expired_at", null: false
    t.integer "remaining_attempts", default: 0
    t.string "verifier_type", null: false
    t.string "phone_number"
    t.datetime "used_at"
    t.string "sms_sender"
    t.string "sms_sid"
    t.string "ip_address"
    t.string "delivery_type"
    t.boolean "ignore_in_rate_limit", default: false, comment: "SMS送信のレートリミットのカウントから除外する"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "idx_users_created_at"
    t.index ["ip_address"], name: "idx_users_ip_address"
    t.index ["phone_number"], name: "idx_users_phone_number"
    t.index ["tenant_id"], name: "index_users__sms_verifiers_on_tenant_id"
    t.index ["user_id"], name: "index_users__sms_verifiers_on_user_id"
  end

  add_foreign_key "account_locks", "tenants", name: "fk_account_locks_tenants"
  add_foreign_key "admins", "tenants", name: "fk_admins_tenants"
  add_foreign_key "auto_tagging_schedules", "tenants"
  add_foreign_key "auto_tagging_schedules", "user_auto_taggings"
  add_foreign_key "contact_addresses", "tenants", name: "fk_contact_addresses_tenants"
  add_foreign_key "contact_addresses", "users", name: "fk_contact_addresses_users"
  add_foreign_key "deliveries", "admins", column: "created_by_id"
  add_foreign_key "deliveries", "admins", column: "published_by_id"
  add_foreign_key "deliveries", "admins", column: "updated_by_id"
  add_foreign_key "deliveries", "templates"
  add_foreign_key "deliveries", "tenants"
  add_foreign_key "delivery_activities", "admins"
  add_foreign_key "delivery_activities", "deliveries"
  add_foreign_key "delivery_activities", "tenants"
  add_foreign_key "delivery_addresses", "tenants", name: "fk_delivery_addresses_tenants"
  add_foreign_key "delivery_addresses", "users", name: "fk_delivery_addresses_users"
  add_foreign_key "delivery_executions", "deliveries"
  add_foreign_key "delivery_executions", "tenants"
  add_foreign_key "delivery_executions", "users"
  add_foreign_key "delivery_user_tags", "deliveries"
  add_foreign_key "delivery_user_tags", "tenants"
  add_foreign_key "delivery_user_tags", "user_tags"
  add_foreign_key "email_templates", "tenants", name: "fk_email_templates_tenants"
  add_foreign_key "komoju_record_accounts", "tenants", name: "fk_komoju_record_accounts_tenants"
  add_foreign_key "komoju_record_payments", "tenants", name: "fk_komoju_payments_tenants"
  add_foreign_key "komoju_record_payments", "users", name: "fk_komoju_payments_users"
  add_foreign_key "login_spa_applications", "tenants", name: "fk_login_spa_applications_tenants"
  add_foreign_key "membership_contract_terms", "membership_contracts", name: "fk_membership_contract_terms_contracts"
  add_foreign_key "membership_contract_terms", "membership_plans", name: "fk_membership_contract_terms_plans"
  add_foreign_key "membership_contract_terms", "tenants", name: "fk_membership_contract_terms_tenants"
  add_foreign_key "membership_contract_terms", "users", name: "fk_membership_contract_terms_users"
  add_foreign_key "membership_contracts", "tenants", name: "fk_membership_contracts_tenants"
  add_foreign_key "membership_contracts", "users", name: "fk_membership_contracts_users"
  add_foreign_key "membership_groups", "tenants", name: "fk_membership_groups_tenants"
  add_foreign_key "membership_plan_components", "membership_plans", name: "fk_membership_plan_components_plans"
  add_foreign_key "membership_plan_components", "memberships", name: "fk_membership_plan_components_memberships"
  add_foreign_key "membership_plan_components", "tenants", name: "fk_membership_plan_components_tenants"
  add_foreign_key "membership_plan_payment_method_mappings", "membership_plan_payment_methods", name: "fk_membership_plan_payment_method_mappings_payment_methods"
  add_foreign_key "membership_plan_payment_method_mappings", "membership_plans", name: "fk_membership_plan_payment_method_mappings_plans"
  add_foreign_key "membership_plan_payment_method_mappings", "tenants", name: "fk_membership_plan_payment_method_mappings_tenants"
  add_foreign_key "membership_plan_payment_methods", "membership_plans", name: "fk_membership_plan_payment_methods_plans"
  add_foreign_key "membership_plan_payment_methods", "tenants", name: "fk_membership_plan_payment_methods_tenants"
  add_foreign_key "membership_plans", "tenants", name: "fk_membership_plans_tenants"
  add_foreign_key "membership_users", "membership_contracts", name: "fk_membership_users_contracts"
  add_foreign_key "membership_users", "membership_groups", name: "fk_membership_users_groups"
  add_foreign_key "membership_users", "memberships", name: "fk_membership_users_memberships"
  add_foreign_key "membership_users", "tenants", name: "fk_membership_users_tenants"
  add_foreign_key "membership_users", "users", name: "fk_membership_users_users"
  add_foreign_key "memberships", "membership_groups", name: "fk_membership_groups"
  add_foreign_key "memberships", "tenants", name: "fk_memberships_tenants"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id", name: "fk_oauth_access_grants_oauth_applications"
  add_foreign_key "oauth_access_grants", "tenants", name: "fk_oauth_access_grants_tenants"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id", name: "fk_oauth_access_tokens_oauth_applications"
  add_foreign_key "oauth_access_tokens", "tenants", name: "fk_oauth_access_tokens_tenants"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "oauth_applications", "tenants", name: "fk_oauth_applications_tenants"
  add_foreign_key "oauth_openid_requests", "oauth_access_grants", column: "access_grant_id", name: "fk_oauth_openid_requests_oauth_access_grants"
  add_foreign_key "payment_subscriptions", "membership_contracts", name: "fk_payment_subscriptions_contracts"
  add_foreign_key "payment_subscriptions", "tenants", name: "fk_payment_subscriptions_tenants"
  add_foreign_key "payment_subscriptions", "users", name: "fk_payment_subscriptions_users"
  add_foreign_key "payment_transactions", "membership_contracts", name: "fk_payment_transactions_contracts"
  add_foreign_key "payment_transactions", "tenants", name: "fk_payment_transactions_tenants"
  add_foreign_key "payment_transactions", "users", name: "fk_payment_transactions_users"
  add_foreign_key "stripe_record_accounts", "stripe_record_accounts", column: "controlling_platform_id", name: "fk_stripe_record_accounts_controlling_platform_id"
  add_foreign_key "stripe_record_accounts", "stripe_record_api_keys", column: "api_key_id", name: "fk_stripe_record_accounts_api_key_id"
  add_foreign_key "stripe_record_accounts", "tenants", name: "fk_stripe_record_accounts_tenants"
  add_foreign_key "stripe_record_api_keys", "tenants", name: "fk_stripe_record_api_keys_tenants"
  add_foreign_key "stripe_record_charges", "stripe_record_accounts", column: "api_key_account_id", name: "fk_stripe_record_charges_api_key_account_id"
  add_foreign_key "stripe_record_charges", "stripe_record_accounts", column: "connect_account_id", name: "fk_stripe_record_charges_connect_account_id"
  add_foreign_key "stripe_record_charges", "stripe_record_payment_intents", column: "payment_intent_id", name: "fk_stripe_record_charges_payment_intents"
  add_foreign_key "stripe_record_charges", "tenants", name: "fk_stripe_record_charges_tenants"
  add_foreign_key "stripe_record_charges", "users", name: "fk_stripe_record_charges_users"
  add_foreign_key "stripe_record_invoices", "tenants", name: "fk_stripe_record_invoices__tenants"
  add_foreign_key "stripe_record_invoices", "users", name: "fk_stripe_record_payment_intents__users"
  add_foreign_key "stripe_record_payment_intents", "stripe_record_accounts", column: "api_key_account_id", name: "fk_stripe_record_payment_intents_api_key_account_id"
  add_foreign_key "stripe_record_payment_intents", "stripe_record_accounts", column: "connect_account_id", name: "fk_stripe_record_payment_intents_connect_account_id"
  add_foreign_key "stripe_record_payment_intents", "stripe_record_invoices", column: "invoice_id", name: "fk_stripe_record_payment_intents__invoices"
  add_foreign_key "stripe_record_payment_intents", "tenants", name: "fk_stripe_record_payment_intents__tenants"
  add_foreign_key "stripe_record_payment_intents", "users", name: "fk_stripe_record_payment_intents__users"
  add_foreign_key "stripe_record_payment_methods", "stripe_record_accounts", column: "api_key_account_id", name: "fk_stripe_record_payment_methods_api_key_account_id"
  add_foreign_key "stripe_record_payment_methods", "stripe_record_accounts", column: "connect_account_id", name: "fk_stripe_record_payment_methods_connect_account_id"
  add_foreign_key "stripe_record_payment_methods", "stripe_record_setup_intents", column: "setup_intent_id", name: "fk_stripe_record_payment_methods__setup_intents"
  add_foreign_key "stripe_record_payment_methods", "tenants", name: "fk_stripe_record_payment_methods__tenants"
  add_foreign_key "stripe_record_payment_methods", "users", name: "fk_stripe_record_payment_methods__users"
  add_foreign_key "stripe_record_prices", "tenants", name: "fk_stripe_record_prices__tenants"
  add_foreign_key "stripe_record_products", "tenants", name: "fk_stripe_record_products__tenants"
  add_foreign_key "stripe_record_refunds", "stripe_record_accounts", column: "api_key_account_id", name: "fk_stripe_record_refunds_api_key_account_id"
  add_foreign_key "stripe_record_refunds", "stripe_record_accounts", column: "connect_account_id", name: "fk_stripe_record_refunds_connect_account_id"
  add_foreign_key "stripe_record_refunds", "stripe_record_payment_intents", column: "payment_intent_id", name: "fk_stripe_record_refunds_payment_intent_id"
  add_foreign_key "stripe_record_refunds", "tenants", name: "fk_stripe_record_payment_intents__tenants"
  add_foreign_key "stripe_record_refunds", "users", name: "fk_stripe_record_refunds__users"
  add_foreign_key "stripe_record_setup_intents", "stripe_record_accounts", column: "api_key_account_id", name: "fk_stripe_record_setup_intents_api_key_account_id"
  add_foreign_key "stripe_record_setup_intents", "stripe_record_accounts", column: "connect_account_id", name: "fk_stripe_record_setup_intents_connect_account_id"
  add_foreign_key "stripe_record_setup_intents", "tenants", name: "fk_stripe_record_setup_intents__tenants"
  add_foreign_key "stripe_record_setup_intents", "users", name: "fk_stripe_record_setup_intents__users"
  add_foreign_key "stripe_record_subscription_items", "stripe_record_prices", column: "price_id", name: "fk_stripe_record_subscription_items__prices"
  add_foreign_key "stripe_record_subscription_items", "stripe_record_subscriptions", column: "subscription_id", name: "fk_stripe_record_subscription_items__subscriptions"
  add_foreign_key "stripe_record_subscription_items", "tenants", name: "fk_stripe_record_subscription_items__tenants"
  add_foreign_key "stripe_record_subscription_schedules", "tenants", name: "fk_stripe_record_subscription_schedules__tenants"
  add_foreign_key "stripe_record_subscriptions", "tenants", name: "fk_stripe_record_subscriptions__tenants"
  add_foreign_key "template_mail_histories", "admins", column: "actor_id", name: "fk_template_mail_histories_actors"
  add_foreign_key "template_mail_histories", "template_mail_versions", column: "version_id", name: "fk_template_mail_histories_versions"
  add_foreign_key "template_mail_histories", "templates", name: "fk_template_mail_histories_templates"
  add_foreign_key "template_mail_histories", "tenants", name: "fk_template_mail_histories_tenants"
  add_foreign_key "template_mail_versions", "admins", column: "published_by_id", name: "fk_template_mail_versions_published_by"
  add_foreign_key "template_mail_versions", "templates", name: "fk_template_mail_versions_templates"
  add_foreign_key "template_mail_versions", "tenants", name: "fk_template_mail_versions_tenants"
  add_foreign_key "template_mails", "templates", name: "fk_template_mails_templates"
  add_foreign_key "template_mails", "tenants", name: "fk_template_mails_tenants"
  add_foreign_key "templates", "tenants", name: "fk_templates_tenants"
  add_foreign_key "tenant_komoju_accounts", "komoju_record_accounts", column: "komoju_account_id", name: "fk_tenant_komoju_accounts_komoju_accounts"
  add_foreign_key "tenant_komoju_accounts", "tenants", name: "fk_tenant_komoju_accounts__tenants"
  add_foreign_key "tenant_stripe_accounts", "stripe_record_accounts", column: "stripe_account_id", name: "fk_tenant_stripe_accounts_stripe_accounts"
  add_foreign_key "tenant_stripe_accounts", "tenants", name: "fk_tenant_stripe_accounts__tenants"
  add_foreign_key "user_auto_tagging_rule_blocks", "tenants"
  add_foreign_key "user_auto_tagging_rule_blocks", "user_auto_taggings"
  add_foreign_key "user_auto_tagging_rules", "tenants"
  add_foreign_key "user_auto_tagging_rules", "user_auto_tagging_rule_blocks", column: "rule_block_id"
  add_foreign_key "user_auto_tagging_tags", "tenants"
  add_foreign_key "user_auto_tagging_tags", "user_auto_taggings"
  add_foreign_key "user_auto_tagging_tags", "user_tags"
  add_foreign_key "user_auto_taggings", "admins", column: "created_by_id"
  add_foreign_key "user_auto_taggings", "admins", column: "updated_by_id"
  add_foreign_key "user_auto_taggings", "tenants"
  add_foreign_key "user_events", "users", column: ["tenant_id", "user_id"], primary_key: ["tenant_id", "id"]
  add_foreign_key "user_profiles", "tenants", name: "fk_user_profiles_tenants"
  add_foreign_key "user_profiles", "users", name: "fk_user_profiles_users"
  add_foreign_key "user_tag_assignments", "admins", column: "assigned_by_id"
  add_foreign_key "user_tag_assignments", "tenants"
  add_foreign_key "user_tag_assignments", "user_auto_taggings"
  add_foreign_key "user_tag_assignments", "user_tags"
  add_foreign_key "user_tag_assignments", "users"
  add_foreign_key "user_tags", "admins", column: "created_by_id"
  add_foreign_key "user_tags", "admins", column: "updated_by_id"
  add_foreign_key "user_tags", "tenants"
  add_foreign_key "users", "tenants", name: "fk_users_tenants"
  add_foreign_key "users__email_verifiers", "tenants", name: "fk_users__email_verifiers_tenants"
  add_foreign_key "users__email_verifiers", "users", name: "fk_users__email_verifiers_users"
  add_foreign_key "users__linked_applications", "oauth_applications", name: "fk_users__linked_applications_oauth_applications"
  add_foreign_key "users__linked_applications", "tenants", name: "fk_users__linked_applications_tenants"
  add_foreign_key "users__linked_applications", "users", name: "fk_users__linked_applications_users"
  add_foreign_key "users__password_resets", "tenants", name: "fk_users__password_resets_tenants"
  add_foreign_key "users__password_resets", "users", name: "fk_users__password_resets_users"
  add_foreign_key "users__sms_verifiers", "tenants", name: "fk_users__sms_verifiers_tenants"
  add_foreign_key "users__sms_verifiers", "users", name: "fk_users__sms_verifiers_users"
end
