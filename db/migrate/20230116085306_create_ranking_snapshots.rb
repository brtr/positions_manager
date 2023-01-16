class CreateRankingSnapshots < ActiveRecord::Migration[6.1]
  def change
    create_table :ranking_snapshots do |t|
      t.string  :symbol
      t.string  :source
      t.decimal :open_price
      t.decimal :last_price
      t.decimal :price_change_rate
      t.decimal :bottom_price_ratio
      t.date    :event_date

      t.timestamps
    end
  end
end
