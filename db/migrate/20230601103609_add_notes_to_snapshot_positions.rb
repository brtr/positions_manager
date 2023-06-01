class AddNotesToSnapshotPositions < ActiveRecord::Migration[6.1]
  def change
    add_column :snapshot_positions, :notes, :text
  end
end
