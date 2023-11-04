class AddColumnsToTransactionsSnapshotInfos < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions_snapshot_infos, :total_cost, :decimal
    add_column :transactions_snapshot_infos, :total_revenue, :decimal
    add_column :transactions_snapshot_infos, :total_roi, :decimal
    add_column :transactions_snapshot_infos, :profit_count, :integer
    add_column :transactions_snapshot_infos, :profit_amount, :decimal
    add_column :transactions_snapshot_infos, :loss_count, :integer
    add_column :transactions_snapshot_infos, :loss_amount, :decimal
    add_column :transactions_snapshot_infos, :max_profit, :decimal
    add_column :transactions_snapshot_infos, :max_loss, :decimal
    add_column :transactions_snapshot_infos, :max_revenue, :decimal
    add_column :transactions_snapshot_infos, :min_revenue, :decimal
    add_column :transactions_snapshot_infos, :max_profit_date, :datetime
    add_column :transactions_snapshot_infos, :max_loss_date, :datetime
    add_column :transactions_snapshot_infos, :max_revenue_date, :datetime
    add_column :transactions_snapshot_infos, :min_revenue_date, :datetime
    add_column :transactions_snapshot_infos, :max_roi, :decimal
    add_column :transactions_snapshot_infos, :max_roi_date, :datetime
    add_column :transactions_snapshot_infos, :max_profit_roi, :decimal
    add_column :transactions_snapshot_infos, :max_profit_roi_date, :datetime
    add_column :transactions_snapshot_infos, :max_loss_roi, :decimal
    add_column :transactions_snapshot_infos, :max_loss_roi_date, :datetime
    add_column :transactions_snapshot_infos, :min_roi, :decimal
    add_column :transactions_snapshot_infos, :min_roi_date, :datetime
  end
end
