class AddIsTop10ToRankingSnapshots < ActiveRecord::Migration[6.1]
  def change
    add_column :ranking_snapshots, :is_top10, :boolean
  end
end
