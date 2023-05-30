class AddCostToOriginTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :origin_transactions, :cost, :decimal, default: 0
  end
end
