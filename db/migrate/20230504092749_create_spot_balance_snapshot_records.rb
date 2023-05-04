class CreateSpotBalanceSnapshotRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :spot_balance_snapshot_records do |t|
      t.integer  :spot_balance_snapshot_info_id
      t.string   :source
      t.string   :origin_symbol
      t.string   :from_symbol
      t.string   :to_symbol
      t.decimal  :price, default: 0, null: false
      t.decimal  :qty, default: 0, null: false
      t.decimal  :amount, default: 0, null: false
      t.datetime :event_date

      t.timestamps
    end

    add_index :spot_balance_snapshot_records, :spot_balance_snapshot_info_id, name: :index_spot_balance_snapshot_info_id
  end
end
