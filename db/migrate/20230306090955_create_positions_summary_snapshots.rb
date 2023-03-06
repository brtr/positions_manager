class CreatePositionsSummarySnapshots < ActiveRecord::Migration[6.1]
  def change
    create_table :positions_summary_snapshots do |t|
      t.decimal :total_cost
      t.decimal :total_revenue
      t.decimal :total_loss
      t.decimal :total_profit
      t.decimal :roi
      t.decimal :revenue_change
      t.date    :event_date

      t.timestamps
    end

    add_index :positions_summary_snapshots, :event_date
  end
end
