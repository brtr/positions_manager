class CreateSnapshotPositions < ActiveRecord::Migration[6.1]
  def change
    create_table :snapshot_positions do |t|
      t.integer :snapshot_info_id
      t.string   :origin_symbol
      t.string   :from_symbol
      t.string   :fee_symbol
      t.string   :trade_type
      t.string   :source
      t.decimal  :price
      t.decimal  :qty
      t.decimal  :amount
      t.decimal  :estimate_price
      t.decimal  :revenue
      t.date     :event_date

      t.timestamps
    end
  end
end
