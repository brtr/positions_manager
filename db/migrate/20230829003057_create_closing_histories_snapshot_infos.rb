class CreateClosingHistoriesSnapshotInfos < ActiveRecord::Migration[6.1]
  def change
    create_table :closing_histories_snapshot_infos do |t|
      t.decimal  :total_cost
      t.decimal  :total_revenue
      t.decimal  :total_roi
      t.integer  :profit_count
      t.decimal  :profit_amount
      t.integer  :loss_count
      t.decimal  :loss_amount
      t.decimal  :max_profit
      t.decimal  :max_loss
      t.decimal  :max_revenue
      t.decimal  :min_revenue
      t.decimal  :max_roi
      t.decimal  :min_roi
      t.datetime :max_profit_date
      t.datetime :max_loss_date
      t.datetime :max_revenue_date
      t.datetime :min_revenue_date
      t.datetime :max_roi_date
      t.datetime :min_roi_date
      t.date     :event_date

      t.timestamps
    end
  end
end
