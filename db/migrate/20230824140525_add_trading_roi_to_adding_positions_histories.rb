class AddTradingRoiToAddingPositionsHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :adding_positions_histories, :trading_roi, :decimal, default: 0
  end
end
