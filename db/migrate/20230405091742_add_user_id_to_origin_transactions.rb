class AddUserIdToOriginTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :origin_transactions, :user_id, :integer
    add_index :origin_transactions, :user_id
  end
end
