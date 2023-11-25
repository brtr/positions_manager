class AddOrderTimeToOpenPositionOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :open_position_orders, :order_time, :datetime
    add_index :open_position_orders, :order_time
  end
end
