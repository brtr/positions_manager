class CreateUserSpotBalances < ActiveRecord::Migration[6.1]
  def change
    create_table :user_spot_balances do |t|
      t.integer :user_id
      t.integer :source
      t.string  :origin_symbol
      t.string  :from_symbol
      t.string  :to_symbol
      t.decimal :amount
      t.decimal :price
      t.decimal :qty

      t.timestamps
    end

    add_index :user_spot_balances, :user_id
  end
end
