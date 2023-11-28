class CreateOpenSpotOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :open_spot_orders do |t|
      t.string   :symbol
      t.string   :order_id
      t.string   :trade_type
      t.string   :status
      t.string   :order_type
      t.decimal  :price
      t.decimal  :stop_price
      t.decimal  :orig_qty
      t.decimal  :executed_qty
      t.decimal  :amount
      t.datetime :order_time

      t.timestamps
    end

    add_index :open_spot_orders, :order_id
    add_index :open_spot_orders, :symbol
    add_index :open_spot_orders, :trade_type
    add_index :open_spot_orders, :order_time
  end
end
