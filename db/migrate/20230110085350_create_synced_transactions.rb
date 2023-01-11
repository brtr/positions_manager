class CreateSyncedTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :synced_transactions do |t|
      t.string   :order_id
      t.string   :trade_type
      t.string   :source
      t.string   :origin_symbol
      t.string   :fee_symbol
      t.decimal  :price
      t.decimal  :qty
      t.decimal  :amount
      t.decimal  :fee
      t.decimal  :revenue
      t.datetime :event_time

      t.timestamps
    end

    add_index :synced_transactions, :order_id
  end
end
