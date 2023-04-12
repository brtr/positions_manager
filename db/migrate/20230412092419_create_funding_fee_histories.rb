class CreateFundingFeeHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :funding_fee_histories do |t|
      t.integer :user_id
      t.string  :origin_symbol
      t.string  :source
      t.decimal :rate
      t.decimal :amount
      t.date    :event_date

      t.timestamps
    end

    add_index :funding_fee_histories, :user_id
    add_index :funding_fee_histories, :origin_symbol
    add_index :funding_fee_histories, :event_date
  end
end
