class CreateTransactionsSnapshotInfos < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions_snapshot_infos do |t|
      t.date :event_date

      t.timestamps
    end

    add_index :transactions_snapshot_infos, :event_date
  end
end
