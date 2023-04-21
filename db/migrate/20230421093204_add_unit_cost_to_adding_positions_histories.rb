class AddUnitCostToAddingPositionsHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :adding_positions_histories, :unit_cost, :decimal, default: 0
  end
end
