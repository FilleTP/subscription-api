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

ActiveRecord::Schema[7.0].define(version: 2025_03_12_200422) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_api_keys_on_key", unique: true
  end

  create_table "coupons", force: :cascade do |t|
    t.string "code", null: false
    t.decimal "discount_percentage", null: false
    t.integer "max_redemptions", default: 1, null: false
    t.integer "redemption_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_coupons_on_code", unique: true
  end

  create_table "plans", force: :cascade do |t|
    t.string "title", null: false
    t.decimal "unit_price", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "external_id", null: false
    t.bigint "plan_id", null: false
    t.integer "seats", default: 1, null: false
    t.decimal "unit_price", null: false
    t.bigint "coupon_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coupon_id"], name: "index_subscriptions_on_coupon_id"
    t.index ["external_id"], name: "index_subscriptions_on_external_id"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
  end

  add_foreign_key "subscriptions", "coupons"
  add_foreign_key "subscriptions", "plans"
end
