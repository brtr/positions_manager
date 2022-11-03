class CreateSnapshotInfos < ActiveRecord::Migration[6.1]
  def change
    create_table :snapshot_infos do |t|
      t.integer :user_id
      t.date    :event_date

      t.timestamps
    end

    add_index :snapshot_infos, :user_id
    add_index :snapshot_infos, :event_date
    add_index :snapshot_infos, [:event_date, :user_id]
  end
end
