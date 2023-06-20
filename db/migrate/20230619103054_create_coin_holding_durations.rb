class CreateCoinHoldingDurations < ActiveRecord::Migration[6.1]
  def change
    create_table :coin_holding_durations do |t|
      t.integer  :user_id
      t.string   :symbol
      t.string   :source
      t.string   :trade_type
      t.bigint   :duration
      t.datetime :start_trading_at

      t.timestamps
    end
  end
end
