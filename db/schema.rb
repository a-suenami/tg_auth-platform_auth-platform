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

  create_table "act_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "act_id", null: false
    t.uuid "entry_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_id", "entry_id"], name: "idx_act_entries_act_id_entry_id_uniq", unique: true
    t.index ["act_id"], name: "index_act_entries_on_act_id"
    t.index ["entry_id"], name: "index_act_entries_on_entry_id"
    t.index ["tenant_id"], name: "index_act_entries_on_tenant_id"
  end

  create_table "act_entry_seat_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "act_entry_seat_id", null: false
    t.uuid "seat_plan_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_entry_seat_id", "seat_plan_id"], name: "idx_act_entry_seat_plans_act_entry_seat_id_seat_plan_id_uniq", unique: true
    t.index ["act_entry_seat_id"], name: "index_act_entry_seat_plans_on_act_entry_seat_id"
    t.index ["seat_plan_id"], name: "index_act_entry_seat_plans_on_seat_plan_id"
    t.index ["tenant_id"], name: "index_act_entry_seat_plans_on_tenant_id"
  end

  create_table "act_entry_seats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "act_entry_id", null: false
    t.uuid "seat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_entry_id", "seat_id"], name: "idx_act_entry_seats_act_entry_id_seat_id_uniq", unique: true
    t.index ["act_entry_id"], name: "index_act_entry_seats_on_act_entry_id"
    t.index ["seat_id"], name: "index_act_entry_seats_on_seat_id"
    t.index ["tenant_id"], name: "index_act_entry_seats_on_tenant_id"
  end

  create_table "act_receptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "act_id", null: false
    t.uuid "reception_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_id", "reception_id"], name: "idx_act_receptions_act_id_reception_id_uniq", unique: true
    t.index ["act_id"], name: "index_act_receptions_on_act_id"
    t.index ["reception_id"], name: "index_act_receptions_on_reception_id"
    t.index ["tenant_id"], name: "index_act_receptions_on_tenant_id"
  end

  create_table "acts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "tour_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_acts_on_tenant_id"
    t.index ["tour_id"], name: "index_acts_on_tour_id"
  end

  create_table "admins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "booth_permission_id", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booth_permission_id"], name: "index_admins_on_booth_permission_id"
    t.index ["tenant_id"], name: "index_admins_on_tenant_id"
    t.index ["uid"], name: "idx_admins_uid_uniq", unique: true
  end

  create_table "available_seat_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "available_seat_id", null: false
    t.uuid "seat_plan_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available_seat_id", "seat_plan_id"], name: "idx_available_seat_plans_available_seat_id_seat_plan_id_uniq", unique: true
    t.index ["available_seat_id"], name: "index_available_seat_plans_on_available_seat_id"
    t.index ["seat_plan_id"], name: "index_available_seat_plans_on_seat_plan_id"
    t.index ["tenant_id"], name: "index_available_seat_plans_on_tenant_id"
  end

  create_table "available_seats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "act_reception_id", null: false
    t.uuid "seat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_reception_id"], name: "index_available_seats_on_act_reception_id"
    t.index ["seat_id", "act_reception_id"], name: "idx_available_seats_seat_id_act_reception_id_uniq", unique: true
    t.index ["seat_id"], name: "index_available_seats_on_seat_id"
    t.index ["tenant_id"], name: "index_available_seats_on_tenant_id"
  end

  create_table "booth_permissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "admin_id", null: false
    t.uuid "booth_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id", "booth_id"], name: "idx_booth_permissions_admin_id_booth_id_uniq", unique: true
    t.index ["admin_id"], name: "index_booth_permissions_on_admin_id"
    t.index ["booth_id"], name: "index_booth_permissions_on_booth_id"
    t.index ["tenant_id"], name: "index_booth_permissions_on_tenant_id"
  end

  create_table "booths", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_booths_on_tenant_id"
  end

  create_table "companions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "act_entry_id", null: false
    t.uuid "accepter_id", null: false
    t.uuid "requester_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accepter_id"], name: "index_companions_on_accepter_id"
    t.index ["act_entry_id", "accepter_id", "requester_id"], name: "idx_companions_act_entry_id_accepter_id_requester_id_uniq", unique: true
    t.index ["act_entry_id"], name: "index_companions_on_act_entry_id"
    t.index ["requester_id"], name: "index_companions_on_requester_id"
    t.index ["tenant_id"], name: "index_companions_on_tenant_id"
  end

  create_table "entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "payment_method_id", null: false
    t.uuid "reception_id", null: false
    t.uuid "user_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_method_id"], name: "index_entries_on_payment_method_id"
    t.index ["reception_id"], name: "index_entries_on_reception_id"
    t.index ["tenant_id"], name: "index_entries_on_tenant_id"
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "news_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_news_items_on_tenant_id"
  end

  create_table "pages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_pages_on_tenant_id"
  end

  create_table "payment_method_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "payment_method_id", null: false
    t.uuid "reception_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_method_id", "reception_id"], name: "idx_payment_method_options_payment_method_id_reception_id_uniq", unique: true
    t.index ["payment_method_id"], name: "index_payment_method_options_on_payment_method_id"
    t.index ["reception_id"], name: "index_payment_method_options_on_reception_id"
    t.index ["tenant_id"], name: "index_payment_method_options_on_tenant_id"
  end

  create_table "payment_methods", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_payment_methods_on_tenant_id"
  end

  create_table "receptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "tour_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_receptions_on_tenant_id"
    t.index ["tour_id"], name: "index_receptions_on_tour_id"
  end

  create_table "seat_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "tour_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_seat_plans_on_tenant_id"
    t.index ["tour_id"], name: "index_seat_plans_on_tour_id"
  end

  create_table "seats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "tour_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_seats_on_tenant_id"
    t.index ["tour_id"], name: "index_seats_on_tour_id"
  end

  create_table "tenants", id: :string, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tours", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "booth_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booth_id"], name: "index_tours_on_booth_id"
    t.index ["tenant_id"], name: "index_tours_on_tenant_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "act_entries", "acts", name: "fk_act_entries_acts"
  add_foreign_key "act_entries", "entries", name: "fk_act_entries_entries"
  add_foreign_key "act_entries", "tenants", name: "fk_act_entries_tenants"
  add_foreign_key "act_entry_seat_plans", "act_entry_seats", name: "fk_act_entry_seat_plans_act_entry_seats"
  add_foreign_key "act_entry_seat_plans", "seat_plans", name: "fk_act_entry_seat_plans_seat_plans"
  add_foreign_key "act_entry_seat_plans", "tenants", name: "fk_act_entry_seat_plans_tenants"
  add_foreign_key "act_entry_seats", "act_entries", name: "fk_act_entry_seats_act_entries"
  add_foreign_key "act_entry_seats", "seats", name: "fk_act_entry_seats_seats"
  add_foreign_key "act_entry_seats", "tenants", name: "fk_act_entry_seats_tenants"
  add_foreign_key "act_receptions", "acts", name: "fk_act_receptions_acts"
  add_foreign_key "act_receptions", "receptions", name: "fk_act_receptions_receptions"
  add_foreign_key "act_receptions", "tenants", name: "fk_act_receptions_tenants"
  add_foreign_key "acts", "tenants", name: "fk_acts_tenants"
  add_foreign_key "acts", "tours", name: "fk_acts_tours"
  add_foreign_key "admins", "booth_permissions", name: "fk_admins_booth_permissions"
  add_foreign_key "admins", "tenants", name: "fk_admins_tenants"
  add_foreign_key "available_seat_plans", "available_seats", name: "fk_available_seat_plans_available_seats"
  add_foreign_key "available_seat_plans", "seat_plans", name: "fk_available_seat_plans_seat_plans"
  add_foreign_key "available_seat_plans", "tenants", name: "fk_available_seat_plans_tenants"
  add_foreign_key "available_seats", "act_receptions", name: "fk_available_seats_act_receptions"
  add_foreign_key "available_seats", "seats", name: "fk_available_seats_seats"
  add_foreign_key "available_seats", "tenants", name: "fk_available_seats_tenants"
  add_foreign_key "booth_permissions", "admins", name: "fk_booth_permissions_admins"
  add_foreign_key "booth_permissions", "booths", name: "fk_booth_permissions_booths"
  add_foreign_key "booths", "tenants", name: "fk_booths_tenants"
  add_foreign_key "companions", "act_entries", name: "fk_companions_act_entries"
  add_foreign_key "companions", "tenants", name: "fk_companions_tenants"
  add_foreign_key "companions", "users", column: "accepter_id", name: "fk_companions_accepters"
  add_foreign_key "companions", "users", column: "requester_id", name: "fk_companions_requesters"
  add_foreign_key "entries", "payment_methods", name: "fk_entries_payment_methods"
  add_foreign_key "entries", "receptions", name: "fk_entries_receptions"
  add_foreign_key "entries", "tenants", name: "fk_entries_tenants"
  add_foreign_key "entries", "users", name: "fk_entries_users"
  add_foreign_key "news_items", "tenants", name: "fk_news_items_tenants"
  add_foreign_key "pages", "tenants", name: "fk_pages_tenants"
  add_foreign_key "payment_method_options", "payment_methods", name: "fk_payment_method_options_payment_methods"
  add_foreign_key "payment_method_options", "receptions", name: "fk_payment_method_options_receptions"
  add_foreign_key "payment_methods", "tenants", name: "fk_payment_methods_tenants"
  add_foreign_key "receptions", "tenants", name: "fk_receptions_tenants"
  add_foreign_key "receptions", "tours", name: "fk_receptions_tours"
  add_foreign_key "seat_plans", "tenants", name: "fk_seat_plans_tenants"
  add_foreign_key "seat_plans", "tours", name: "fk_seat_plans_tours"
  add_foreign_key "seats", "tenants", name: "fk_seats_tenants"
  add_foreign_key "seats", "tours", name: "fk_seats_tours"
  add_foreign_key "tours", "booths", name: "fk_tours_booths"
  add_foreign_key "tours", "tenants", name: "fk_tours_tenants"
  add_foreign_key "users", "tenants", name: "fk_users_tenants"
end
