class CreateCombineTxSnapshotInfos < ActiveRecord::Migration[6.1]
  def change
    create_table :combine_tx_snapshot_infos do |t|
      t.date :event_date

      t.timestamps
    end
  end
end
