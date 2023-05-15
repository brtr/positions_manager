class AddLevelToUserSpotBalances < ActiveRecord::Migration[6.1]
  def change
    add_column :user_spot_balances, :level, :integer
  end
end
