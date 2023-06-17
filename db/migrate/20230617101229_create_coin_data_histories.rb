class CreateCoinDataHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :coin_data_histories do |t|
      t.string :symbol
      t.string :source
      t.json   :open_interest
      t.json   :top_long_short_account_ratio
      t.json   :top_long_short_position_ratio
      t.json   :global_long_short_account_ratio
      t.json   :taker_long_short_ratio
      t.date   :event_date

      t.timestamps
    end

    add_index :coin_data_histories, :symbol
    add_index :coin_data_histories, :source
    add_index :coin_data_histories, :event_date
  end
end
