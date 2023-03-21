class AddMaxRoiAndMinRoiToSnapshotInfos < ActiveRecord::Migration[6.1]
  def change
    add_column :snapshot_infos, :max_roi, :decimal
    add_column :snapshot_infos, :max_roi_date, :datetime
    add_column :snapshot_infos, :min_roi, :decimal
    add_column :snapshot_infos, :min_roi_date, :datetime
  end
end
