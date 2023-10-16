class AddSoldRevenueToCombineTxSnapshotRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :combine_tx_snapshot_records, :sold_revenue, :decimal, default: 0
  end
end
