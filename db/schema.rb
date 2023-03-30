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

  create_table "contact_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.boolean "is_default"
    t.string "zip_code"
    t.integer "prefecture_code"
    t.string "city"
    t.string "address1"
    t.string "address2"
    t.string "contact_tel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_contact_addresses_on_tenant_id"
    t.index ["user_id"], name: "index_contact_addresses_on_user_id"
  end

  create_table "delivary_address", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.boolean "is_default"
    t.string "zip_code"
    t.integer "prefecture_code"
    t.string "city"
    t.string "address1"
    t.string "address2"
    t.string "contact_tel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_delivary_address_on_tenant_id"
    t.index ["user_id"], name: "index_delivary_address_on_user_id"
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
    t.string "last_name_kane"
    t.date "birth_date"
    t.string "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_user_profiles_on_tenant_id"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "uid", null: false
    t.string "email"
    t.string "encrypted_password"
    t.string "tel"
    t.boolean "tel_verified", default: false
    t.string "email_confirm_code"
    t.boolean "email_verified", default: false
    t.string "password_reset_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "contact_addresses", "tenants", name: "fk_contact_addresses_tenants"
  add_foreign_key "contact_addresses", "users", name: "fk_contact_addresses_users"
  add_foreign_key "delivary_address", "tenants", name: "fk_delivary_address_tenants"
  add_foreign_key "delivary_address", "users", name: "fk_delivary_address_users"
  add_foreign_key "user_profiles", "tenants", name: "fk_user_profiles_tenants"
  add_foreign_key "user_profiles", "users", name: "fk_user_profiles_users"
  add_foreign_key "users", "tenants", name: "fk_users_tenants"
end
