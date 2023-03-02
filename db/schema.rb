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

ActiveRecord::Schema.define(version: 2023_03_02_084226) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "adding_positions_histories", force: :cascade do |t|
    t.string "origin_symbol"
    t.string "from_symbol"
    t.string "fee_symbol"
    t.string "source"
    t.string "trade_type"
    t.decimal "price"
    t.decimal "qty"
    t.decimal "amount"
    t.decimal "current_price"
    t.decimal "revenue"
    t.decimal "roi"
    t.decimal "amount_ratio"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_date"], name: "index_adding_positions_histories_on_event_date"
    t.index ["origin_symbol"], name: "index_adding_positions_histories_on_origin_symbol"
  end

  create_table "combine_transactions", force: :cascade do |t|
    t.string "source"
    t.string "original_symbol"
    t.string "from_symbol"
    t.string "to_symbol"
    t.string "trade_type"
    t.string "fee_symbol"
    t.decimal "price", default: "0.0", null: false
    t.decimal "qty", default: "0.0", null: false
    t.decimal "amount", default: "0.0", null: false
    t.decimal "fee", default: "0.0", null: false
    t.decimal "revenue", default: "0.0", null: false
    t.decimal "roi", default: "0.0", null: false
    t.decimal "current_price", default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["original_symbol"], name: "index_combine_transactions_on_original_symbol"
    t.index ["source"], name: "index_combine_transactions_on_source"
  end

  create_table "origin_transactions", force: :cascade do |t|
    t.string "order_id"
    t.string "source"
    t.string "original_symbol"
    t.string "from_symbol"
    t.string "to_symbol"
    t.string "fee_symbol"
    t.string "trade_type"
    t.string "campaign"
    t.decimal "price", default: "0.0", null: false
    t.decimal "qty", default: "0.0", null: false
    t.decimal "amount", default: "0.0", null: false
    t.decimal "fee", default: "0.0", null: false
    t.decimal "revenue", default: "0.0", null: false
    t.decimal "roi", default: "0.0", null: false
    t.decimal "current_price", default: "0.0", null: false
    t.datetime "event_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign"], name: "index_origin_transactions_on_campaign"
    t.index ["order_id"], name: "index_origin_transactions_on_order_id"
    t.index ["source"], name: "index_origin_transactions_on_source"
  end

  create_table "ranking_snapshots", force: :cascade do |t|
    t.string "symbol"
    t.string "source"
    t.decimal "open_price"
    t.decimal "last_price"
    t.decimal "price_change_rate"
    t.decimal "bottom_price_ratio"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_top10"
  end

  create_table "snapshot_infos", force: :cascade do |t|
    t.integer "user_id"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "source_type"
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
    t.decimal "margin_ratio"
    t.decimal "last_revenue"
  end

  create_table "synced_transactions", force: :cascade do |t|
    t.string "order_id"
    t.string "trade_type"
    t.string "source"
    t.string "origin_symbol"
    t.string "fee_symbol"
    t.decimal "price"
    t.decimal "qty"
    t.decimal "amount"
    t.decimal "fee"
    t.decimal "revenue"
    t.datetime "event_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_synced_transactions_on_order_id"
  end

  create_table "transactions_snapshot_infos", force: :cascade do |t|
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_date"], name: "index_transactions_snapshot_infos_on_event_date"
  end

  create_table "transactions_snapshot_records", force: :cascade do |t|
    t.integer "transactions_snapshot_info_id"
    t.string "order_id"
    t.string "source"
    t.string "original_symbol"
    t.string "from_symbol"
    t.string "to_symbol"
    t.string "fee_symbol"
    t.string "trade_type"
    t.string "campaign"
    t.decimal "price", default: "0.0", null: false
    t.decimal "qty", default: "0.0", null: false
    t.decimal "amount", default: "0.0", null: false
    t.decimal "fee", default: "0.0", null: false
    t.decimal "revenue", default: "0.0", null: false
    t.decimal "roi", default: "0.0", null: false
    t.decimal "current_price", default: "0.0", null: false
    t.datetime "event_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["transactions_snapshot_info_id"], name: "index_snapshot_info_id"
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

  create_table "user_synced_positions", force: :cascade do |t|
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
    t.index ["user_id"], name: "index_user_synced_positions_on_user_id"
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
    t.string "api_key"
    t.string "secret_key"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
