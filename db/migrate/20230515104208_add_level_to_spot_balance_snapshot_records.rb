class AddLevelToSpotBalanceSnapshotRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :spot_balance_snapshot_records, :level, :integer
  end
end
