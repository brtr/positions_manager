class CreateOpenPositionOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :open_position_orders do |t|
      t.string :symbol
      t.string :order_id
      t.string :trade_type
      t.string :position_side
      t.string :status
      t.string :order_type
      t.decimal :price
      t.decimal :stop_price
      t.decimal :orig_qty
      t.decimal :amount

      t.timestamps
    end

    add_index :open_position_orders, :order_id
    add_index :open_position_orders, :symbol
    add_index :open_position_orders, :trade_type
    add_index :open_position_orders, :position_side
  end
end
