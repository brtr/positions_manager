class AddCurrentPriceToOpenSpotOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :open_spot_orders, :current_price, :decimal
  end
end
