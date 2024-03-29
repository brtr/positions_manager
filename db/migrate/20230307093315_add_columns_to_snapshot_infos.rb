class AddColumnsToSnapshotInfos < ActiveRecord::Migration[6.1]
  def change
    add_column :snapshot_infos, :increase_count, :integer
    add_column :snapshot_infos, :decrease_count, :integer
    add_column :snapshot_infos, :btc_change, :decimal
    add_column :snapshot_infos, :btc_change_ratio, :decimal
    add_column :snapshot_infos, :total_cost, :decimal
    add_column :snapshot_infos, :total_revenue, :decimal
    add_column :snapshot_infos, :total_roi, :decimal
    add_column :snapshot_infos, :profit_count, :integer
    add_column :snapshot_infos, :profit_amount, :decimal
    add_column :snapshot_infos, :loss_count, :integer
    add_column :snapshot_infos, :loss_amount, :decimal
    add_column :snapshot_infos, :max_profit, :decimal
    add_column :snapshot_infos, :max_loss, :decimal
    add_column :snapshot_infos, :max_revenue, :decimal
    add_column :snapshot_infos, :min_revenue, :decimal
    add_column :snapshot_infos, :max_profit_date, :datetime
    add_column :snapshot_infos, :max_loss_date, :datetime
    add_column :snapshot_infos, :max_revenue_date, :datetime
    add_column :snapshot_infos, :min_revenue_date, :datetime
  end
end
