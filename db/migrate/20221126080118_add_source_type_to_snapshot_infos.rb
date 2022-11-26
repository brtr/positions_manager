class AddSourceTypeToSnapshotInfos < ActiveRecord::Migration[6.1]
  def change
    add_column :snapshot_infos, :source_type, :integer
  end
end
