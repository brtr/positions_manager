class AddIndexToTransactionsSnapshotRecords < ActiveRecord::Migration[6.1]
  def change
    add_index :transactions_snapshot_records, :from_symbol
    add_index :transactions_snapshot_records, :amount
    add_index :transactions_snapshot_records, :event_time
    add_index :transactions_snapshot_records, :revenue
    add_index :transactions_snapshot_records, :trade_type
  end
end
