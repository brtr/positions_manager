class CreateCoinRankings < ActiveRecord::Migration[6.1]
  def change
    create_table :coin_rankings do |t|
      t.string  :symbol
      t.integer :rank

      t.timestamps
    end

    add_index :coin_rankings, :symbol
  end
end
