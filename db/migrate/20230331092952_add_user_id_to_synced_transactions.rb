class AddUserIdToSyncedTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :synced_transactions, :user_id, :integer
    add_index :synced_transactions, :user_id
  end
end
