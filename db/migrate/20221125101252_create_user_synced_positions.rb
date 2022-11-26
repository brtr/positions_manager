class CreateUserSyncedPositions < ActiveRecord::Migration[6.1]
  def change
    create_table :user_synced_positions do |t|
      t.integer :user_id
      t.integer :source
      t.string  :origin_symbol
      t.string  :from_symbol
      t.string  :fee_symbol
      t.string  :trade_type
      t.decimal :qty
      t.decimal :price
      t.decimal :current_price
      t.decimal :margin_ratio
      t.decimal :last_revenue

      t.timestamps
    end

    add_index :user_synced_positions, :user_id
  end
end
