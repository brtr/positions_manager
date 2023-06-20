class AddQtyToCoinHoldingDurations < ActiveRecord::Migration[6.1]
  def change
    add_column :coin_holding_durations, :qty, :decimal, default: 0
  end
end
