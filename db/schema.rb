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

ActiveRecord::Schema.define(version: 2022_11_03_080255) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "snapshot_infos", force: :cascade do |t|
    t.integer "user_id"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_date", "user_id"], name: "index_snapshot_infos_on_event_date_and_user_id"
    t.index ["event_date"], name: "index_snapshot_infos_on_event_date"
    t.index ["user_id"], name: "index_snapshot_infos_on_user_id"
  end

  create_table "snapshot_positions", force: :cascade do |t|
    t.integer "snapshot_info_id"
    t.string "origin_symbol"
    t.string "from_symbol"
    t.string "fee_symbol"
    t.string "trade_type"
    t.string "source"
    t.decimal "price"
    t.decimal "qty"
    t.decimal "amount"
    t.decimal "estimate_price"
    t.decimal "revenue"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_positions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "source"
    t.string "origin_symbol"
    t.string "from_symbol"
    t.string "fee_symbol"
    t.string "trade_type"
    t.decimal "qty"
    t.decimal "price"
    t.decimal "current_price"
    t.decimal "margin_ratio"
    t.decimal "last_revenue"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_positions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "admin", default: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
