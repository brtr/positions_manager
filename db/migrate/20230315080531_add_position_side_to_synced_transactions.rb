class AddPositionSideToSyncedTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :synced_transactions, :position_side, :string
  end
end
