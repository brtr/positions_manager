class CreateSpotBalanceSnapshotInfos < ActiveRecord::Migration[6.1]
  def change
    create_table :spot_balance_snapshot_infos do |t|
      t.integer :user_id
      t.date    :event_date

      t.timestamps
    end

    add_index :spot_balance_snapshot_infos, :user_id
    add_index :spot_balance_snapshot_infos, :event_date
  end
end
