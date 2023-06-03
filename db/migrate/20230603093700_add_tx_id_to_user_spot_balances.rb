class AddTxIdToUserSpotBalances < ActiveRecord::Migration[6.1]
  def change
    add_column :user_spot_balances, :tx_id, :integer

    add_index :user_spot_balances, :tx_id
  end
end
