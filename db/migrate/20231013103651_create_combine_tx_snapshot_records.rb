class CreateCombineTxSnapshotRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :combine_tx_snapshot_records do |t|
      t.references :combine_tx_snapshot_info, index: { name: 'index_snapshot_info' }
      t.string :source
      t.string :original_symbol
      t.string :from_symbol
      t.string :to_symbol
      t.string :trade_type
      t.string :fee_symbol
      t.decimal :price, default: "0.0", null: false
      t.decimal :qty, default: "0.0", null: false
      t.decimal :amount, default: "0.0", null: false
      t.decimal :fee, default: "0.0", null: false
      t.decimal :revenue, default: "0.0", null: false
      t.decimal :roi, default: "0.0", null: false
      t.decimal :current_price, default: "0.0", null: false

      t.timestamps
    end
  end
end
