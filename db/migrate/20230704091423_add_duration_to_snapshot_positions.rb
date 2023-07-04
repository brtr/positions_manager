class AddDurationToSnapshotPositions < ActiveRecord::Migration[6.1]
  def change
    add_column :snapshot_positions, :average_durations, :integer
  end
end
