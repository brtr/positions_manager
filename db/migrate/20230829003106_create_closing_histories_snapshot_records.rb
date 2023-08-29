class CreateClosingHistoriesSnapshotRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :closing_histories_snapshot_records do |t|
      t.references :closing_histories_snapshot_info, index: { name: 'index_closing_histories_snapshot_info_id' }
      t.string :origin_symbol
      t.string :from_symbol
      t.string :fee_symbol
      t.string :source
      t.string :trade_type
      t.decimal :price
      t.decimal :qty
      t.decimal :amount
      t.decimal :current_price
      t.decimal :revenue
      t.decimal :roi
      t.decimal :amount_ratio
      t.decimal :unit_cost, default: "0.0"
      t.decimal :trading_roi, default: "0.0"
      t.date    :event_date

      t.timestamps
    end
  end
end
