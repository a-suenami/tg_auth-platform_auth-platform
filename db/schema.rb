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

ActiveRecord::Schema[7.0].define(version: 0) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "admins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "name"
    t.string "email"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_admins_on_tenant_id"
  end

  create_table "contact_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.string "zip_code"
    t.integer "prefecture_code"
    t.string "city"
    t.string "address_1"
    t.string "address_2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_contact_addresses_on_tenant_id"
    t.index ["user_id"], name: "index_contact_addresses_on_user_id"
  end

  create_table "delivery_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.boolean "is_default"
    t.string "zip_code"
    t.integer "prefecture_code"
    t.string "city"
    t.string "address_1"
    t.string "address_2"
    t.string "contact_tel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_delivery_addresses_on_tenant_id"
    t.index ["user_id"], name: "index_delivery_addresses_on_user_id"
  end

  create_table "email_templates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "name", null: false
    t.string "template_type", null: false
    t.string "subject", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_email_templates_on_tenant_id"
  end

  create_table "login_spa_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "name", null: false
    t.string "uid", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "login_url"
    t.string "redirect_url_on_password_reset"
    t.index ["tenant_id"], name: "index_login_spa_applications_on_tenant_id"
    t.index ["uid"], name: "index_login_spa_applications_on_uid", unique: true
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
    t.index ["tenant_id"], name: "index_oauth_applications_on_tenant_id"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "oauth_openid_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "access_grant_id", null: false
    t.string "nonce", null: false
    t.index ["access_grant_id"], name: "index_oauth_openid_requests_on_access_grant_id"
  end

  create_table "tenants", id: :citext, force: :cascade do |t|
    t.string "name"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["tenant_id"], name: "index_user_profiles_on_tenant_id"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "email"
    t.string "password_digest"
    t.boolean "enabled", default: false
    t.string "tel"
    t.boolean "tel_verified", default: false
    t.boolean "email_verified", default: false
    t.string "password_reset_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "email"], name: "index_users_on_tenant_id_email", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  create_table "users__email_verifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.string "code", null: false
    t.datetime "expired_at", null: false
    t.integer "remaining_attempts", default: 0
    t.string "email_verifier_type"
    t.string "email"
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_users__email_verifiers_on_tenant_id"
    t.index ["user_id"], name: "index_users__email_verifiers_on_user_id"
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

  add_foreign_key "admins", "tenants", name: "fk_admins_tenants"
  add_foreign_key "contact_addresses", "tenants", name: "fk_contact_addresses_tenants"
  add_foreign_key "contact_addresses", "users", name: "fk_contact_addresses_users"
  add_foreign_key "delivery_addresses", "tenants", name: "fk_delivery_addresses_tenants"
  add_foreign_key "delivery_addresses", "users", name: "fk_delivery_addresses_users"
  add_foreign_key "email_templates", "tenants", name: "fk_email_templates_tenants"
  add_foreign_key "login_spa_applications", "tenants", name: "fk_login_spa_applications_tenants"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id", name: "fk_oauth_access_grants_oauth_applications"
  add_foreign_key "oauth_access_grants", "tenants", name: "fk_oauth_access_grants_tenants"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id", name: "fk_oauth_access_tokens_oauth_applications"
  add_foreign_key "oauth_access_tokens", "tenants", name: "fk_oauth_access_tokens_tenants"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "oauth_applications", "tenants", name: "fk_oauth_applications_tenants"
  add_foreign_key "oauth_openid_requests", "oauth_access_grants", column: "access_grant_id", name: "fk_oauth_openid_requests_oauth_access_grants"
  add_foreign_key "user_profiles", "tenants", name: "fk_user_profiles_tenants"
  add_foreign_key "user_profiles", "users", name: "fk_user_profiles_users"
  add_foreign_key "users", "tenants", name: "fk_users_tenants"
  add_foreign_key "users__email_verifiers", "tenants", name: "fk_users__email_verifiers_tenants"
  add_foreign_key "users__email_verifiers", "users", name: "fk_users__email_verifiers_users"
  add_foreign_key "users__password_resets", "tenants", name: "fk_users__password_resets_tenants"
  add_foreign_key "users__password_resets", "users", name: "fk_users__password_resets_users"
end
