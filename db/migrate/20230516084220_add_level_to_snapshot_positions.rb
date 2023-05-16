class AddLevelToSnapshotPositions < ActiveRecord::Migration[6.1]
  def change
    add_column :snapshot_positions, :level, :integer
  end
end
