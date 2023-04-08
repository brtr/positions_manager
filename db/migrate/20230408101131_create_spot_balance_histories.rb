class CreateSpotBalanceHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :spot_balance_histories do |t|
      t.integer :user_id
      t.string  :asset
      t.string  :source
      t.decimal :free
      t.decimal :locked
      t.date    :event_date

      t.timestamps
    end

    add_index :spot_balance_histories, :user_id
    add_index :spot_balance_histories, :source
    add_index :spot_balance_histories, :event_date
  end
end
