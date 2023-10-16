class AddSoldRevenueToCombineTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :combine_transactions, :sold_revenue, :decimal, default: 0
  end
end
