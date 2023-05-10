class AddEstimatePriceAndRevenueToSpotBalanceSnapshotRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :spot_balance_snapshot_records, :estimate_price, :decimal
    add_column :spot_balance_snapshot_records, :revenue, :decimal, default: 0
  end
end
