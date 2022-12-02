class AddColumnsSnapshotPositions < ActiveRecord::Migration[6.1]
  def change
    add_column :snapshot_positions, :margin_ratio, :decimal
    add_column :snapshot_positions, :last_revenue, :decimal
  end
end
