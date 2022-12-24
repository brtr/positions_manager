class CreateOriginTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :origin_transactions do |t|
      t.string   :order_id
      t.string   :source
      t.string   :original_symbol
      t.string   :from_symbol
      t.string   :to_symbol
      t.string   :fee_symbol
      t.string   :trade_type
      t.string   :campaign
      t.decimal  :price, default: 0, null: false
      t.decimal  :qty, default: 0, null: false
      t.decimal  :amount, default: 0, null: false
      t.decimal  :fee, default: 0, null: false
      t.decimal  :revenue, default: 0, null: false
      t.decimal  :roi, default: 0, null: false
      t.decimal  :current_price, default: 0, null: false
      t.datetime :event_time

      t.timestamps
    end

    add_index :origin_transactions, :order_id
    add_index :origin_transactions, :source
    add_index :origin_transactions, :campaign
  end
end
