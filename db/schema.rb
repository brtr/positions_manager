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

ActiveRecord::Schema.define(version: 2023_12_04_085731) do

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
    t.decimal "unit_cost", default: "0.0"
    t.decimal "trading_roi", default: "0.0"
    t.index ["event_date"], name: "index_adding_positions_histories_on_event_date"
    t.index ["origin_symbol"], name: "index_adding_positions_histories_on_origin_symbol"
  end

  create_table "attachments", force: :cascade do |t|
    t.bigint "user_positions_notes_history_id"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_positions_notes_history_id"], name: "index_attachments_on_user_positions_notes_history_id"
  end

  create_table "binance_positions", force: :cascade do |t|
    t.string "symbol"
    t.decimal "price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "closing_histories_snapshot_infos", force: :cascade do |t|
    t.decimal "total_cost"
    t.decimal "total_revenue"
    t.decimal "total_roi"
    t.integer "profit_count"
    t.decimal "profit_amount"
    t.integer "loss_count"
    t.decimal "loss_amount"
    t.decimal "max_profit"
    t.decimal "max_loss"
    t.decimal "max_revenue"
    t.decimal "min_revenue"
    t.decimal "max_roi"
    t.decimal "min_roi"
    t.datetime "max_profit_date"
    t.datetime "max_loss_date"
    t.datetime "max_revenue_date"
    t.datetime "min_revenue_date"
    t.datetime "max_roi_date"
    t.datetime "min_roi_date"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "closing_histories_snapshot_records", force: :cascade do |t|
    t.bigint "closing_histories_snapshot_info_id"
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
    t.decimal "unit_cost", default: "0.0"
    t.decimal "trading_roi", default: "0.0"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["closing_histories_snapshot_info_id"], name: "index_closing_histories_snapshot_info_id"
  end

  create_table "coin_data_histories", force: :cascade do |t|
    t.string "symbol"
    t.string "source"
    t.json "open_interest"
    t.json "top_long_short_account_ratio"
    t.json "top_long_short_position_ratio"
    t.json "global_long_short_account_ratio"
    t.json "taker_long_short_ratio"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_date"], name: "index_coin_data_histories_on_event_date"
    t.index ["source"], name: "index_coin_data_histories_on_source"
    t.index ["symbol"], name: "index_coin_data_histories_on_symbol"
  end

  create_table "coin_holding_durations", force: :cascade do |t|
    t.integer "user_id"
    t.string "symbol"
    t.string "source"
    t.string "trade_type"
    t.bigint "duration"
    t.datetime "start_trading_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "qty", default: "0.0"
  end

  create_table "coin_rankings", force: :cascade do |t|
    t.string "symbol"
    t.integer "rank"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["symbol"], name: "index_coin_rankings_on_symbol"
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
    t.decimal "sold_revenue", default: "0.0"
    t.index ["original_symbol"], name: "index_combine_transactions_on_original_symbol"
    t.index ["source"], name: "index_combine_transactions_on_source"
  end

  create_table "combine_tx_snapshot_infos", force: :cascade do |t|
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "combine_tx_snapshot_records", force: :cascade do |t|
    t.bigint "combine_tx_snapshot_info_id"
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
    t.decimal "sold_revenue", default: "0.0"
    t.index ["combine_tx_snapshot_info_id"], name: "index_snapshot_info"
  end

  create_table "funding_fee_histories", force: :cascade do |t|
    t.integer "user_id"
    t.string "origin_symbol"
    t.string "source"
    t.decimal "rate"
    t.decimal "amount"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "snapshot_position_id"
    t.string "trade_type"
    t.index ["event_date"], name: "index_funding_fee_histories_on_event_date"
    t.index ["origin_symbol"], name: "index_funding_fee_histories_on_origin_symbol"
    t.index ["user_id"], name: "index_funding_fee_histories_on_user_id"
  end

  create_table "open_position_orders", force: :cascade do |t|
    t.string "symbol"
    t.string "order_id"
    t.string "trade_type"
    t.string "position_side"
    t.string "status"
    t.string "order_type"
    t.decimal "price"
    t.decimal "stop_price"
    t.decimal "orig_qty"
    t.decimal "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "order_time"
    t.index ["order_id"], name: "index_open_position_orders_on_order_id"
    t.index ["order_time"], name: "index_open_position_orders_on_order_time"
    t.index ["position_side"], name: "index_open_position_orders_on_position_side"
    t.index ["symbol"], name: "index_open_position_orders_on_symbol"
    t.index ["trade_type"], name: "index_open_position_orders_on_trade_type"
  end

  create_table "open_spot_orders", force: :cascade do |t|
    t.string "symbol"
    t.string "order_id"
    t.string "trade_type"
    t.string "status"
    t.string "order_type"
    t.decimal "price"
    t.decimal "stop_price"
    t.decimal "orig_qty"
    t.decimal "executed_qty"
    t.decimal "amount"
    t.datetime "order_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "current_price"
    t.index ["order_id"], name: "index_open_spot_orders_on_order_id"
    t.index ["order_time"], name: "index_open_spot_orders_on_order_time"
    t.index ["symbol"], name: "index_open_spot_orders_on_symbol"
    t.index ["trade_type"], name: "index_open_spot_orders_on_trade_type"
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
    t.integer "user_id"
    t.decimal "cost", default: "0.0"
    t.index ["campaign"], name: "index_origin_transactions_on_campaign"
    t.index ["order_id"], name: "index_origin_transactions_on_order_id"
    t.index ["source"], name: "index_origin_transactions_on_source"
    t.index ["trade_type"], name: "index_origin_transactions_on_trade_type"
    t.index ["user_id", "trade_type"], name: "index_origin_transactions_on_user_id_and_trade_type"
    t.index ["user_id"], name: "index_origin_transactions_on_user_id"
  end

  create_table "positions_summary_snapshots", force: :cascade do |t|
    t.decimal "total_cost"
    t.decimal "total_revenue"
    t.decimal "total_loss"
    t.decimal "total_profit"
    t.decimal "roi"
    t.decimal "revenue_change"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_date"], name: "index_positions_summary_snapshots_on_event_date"
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
    t.integer "increase_count"
    t.integer "decrease_count"
    t.decimal "btc_change"
    t.decimal "btc_change_ratio"
    t.decimal "total_cost"
    t.decimal "total_revenue"
    t.decimal "total_roi"
    t.integer "profit_count"
    t.decimal "profit_amount"
    t.integer "loss_count"
    t.decimal "loss_amount"
    t.decimal "max_profit"
    t.decimal "max_loss"
    t.decimal "max_revenue"
    t.decimal "min_revenue"
    t.datetime "max_profit_date"
    t.datetime "max_loss_date"
    t.datetime "max_revenue_date"
    t.datetime "min_revenue_date"
    t.decimal "max_roi"
    t.datetime "max_roi_date"
    t.decimal "min_roi"
    t.datetime "min_roi_date"
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
    t.integer "level"
    t.text "notes"
    t.integer "average_durations"
  end

  create_table "spot_balance_histories", force: :cascade do |t|
    t.integer "user_id"
    t.string "asset"
    t.string "source"
    t.decimal "free"
    t.decimal "locked"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_date"], name: "index_spot_balance_histories_on_event_date"
    t.index ["source"], name: "index_spot_balance_histories_on_source"
    t.index ["user_id"], name: "index_spot_balance_histories_on_user_id"
  end

  create_table "spot_balance_snapshot_infos", force: :cascade do |t|
    t.integer "user_id"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_date"], name: "index_spot_balance_snapshot_infos_on_event_date"
    t.index ["user_id"], name: "index_spot_balance_snapshot_infos_on_user_id"
  end

  create_table "spot_balance_snapshot_records", force: :cascade do |t|
    t.integer "spot_balance_snapshot_info_id"
    t.string "source"
    t.string "origin_symbol"
    t.string "from_symbol"
    t.string "to_symbol"
    t.decimal "price", default: "0.0", null: false
    t.decimal "qty", default: "0.0", null: false
    t.decimal "amount", default: "0.0", null: false
    t.datetime "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "estimate_price"
    t.decimal "revenue", default: "0.0"
    t.integer "level"
    t.index ["spot_balance_snapshot_info_id"], name: "index_spot_balance_snapshot_info_id"
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
    t.string "position_side"
    t.integer "user_id"
    t.index ["order_id"], name: "index_synced_transactions_on_order_id"
    t.index ["user_id"], name: "index_synced_transactions_on_user_id"
  end

  create_table "transactions_snapshot_infos", force: :cascade do |t|
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "total_cost"
    t.decimal "total_revenue"
    t.decimal "total_roi"
    t.integer "profit_count"
    t.decimal "profit_amount"
    t.integer "loss_count"
    t.decimal "loss_amount"
    t.decimal "max_profit"
    t.decimal "max_loss"
    t.decimal "max_revenue"
    t.decimal "min_revenue"
    t.datetime "max_profit_date"
    t.datetime "max_loss_date"
    t.datetime "max_revenue_date"
    t.datetime "min_revenue_date"
    t.decimal "max_roi"
    t.datetime "max_roi_date"
    t.decimal "max_profit_roi"
    t.datetime "max_profit_roi_date"
    t.decimal "max_loss_roi"
    t.datetime "max_loss_roi_date"
    t.decimal "min_roi"
    t.datetime "min_roi_date"
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
    t.index ["amount"], name: "index_transactions_snapshot_records_on_amount"
    t.index ["event_time"], name: "index_transactions_snapshot_records_on_event_time"
    t.index ["from_symbol"], name: "index_transactions_snapshot_records_on_from_symbol"
    t.index ["revenue"], name: "index_transactions_snapshot_records_on_revenue"
    t.index ["trade_type"], name: "index_transactions_snapshot_records_on_trade_type"
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
    t.integer "level"
    t.text "notes"
    t.index ["user_id"], name: "index_user_positions_on_user_id"
  end

  create_table "user_positions_notes_histories", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "user_position_id"
    t.text "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_positions_notes_histories_on_user_id"
    t.index ["user_position_id"], name: "index_user_positions_notes_histories_on_user_position_id"
  end

  create_table "user_spot_balances", force: :cascade do |t|
    t.integer "user_id"
    t.integer "source"
    t.string "origin_symbol"
    t.string "from_symbol"
    t.string "to_symbol"
    t.decimal "amount"
    t.decimal "price"
    t.decimal "qty"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "level"
    t.integer "tx_id"
    t.index ["tx_id"], name: "index_user_spot_balances_on_tx_id"
    t.index ["user_id"], name: "index_user_spot_balances_on_user_id"
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
    t.string "okx_api_key"
    t.string "okx_secret_key"
    t.string "okx_passphrase"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallet_histories", force: :cascade do |t|
    t.integer "user_id"
    t.integer "trade_type"
    t.integer "transfer_type"
    t.string "order_no"
    t.string "network"
    t.string "symbol"
    t.boolean "is_completed"
    t.decimal "amount", default: "0.0"
    t.decimal "fee", default: "0.0"
    t.datetime "apply_time"
    t.datetime "complete_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["is_completed"], name: "index_wallet_histories_on_is_completed"
    t.index ["order_no"], name: "index_wallet_histories_on_order_no"
    t.index ["trade_type"], name: "index_wallet_histories_on_trade_type"
    t.index ["transfer_type"], name: "index_wallet_histories_on_transfer_type"
    t.index ["user_id"], name: "index_wallet_histories_on_user_id"
  end

end
