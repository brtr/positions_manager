class CreateAddingPositionsHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :adding_positions_histories do |t|
      t.string  :origin_symbol
      t.string  :from_symbol
      t.string  :fee_symbol
      t.string  :source
      t.string  :trade_type
      t.decimal :price
      t.decimal :qty
      t.decimal :amount
      t.decimal :current_price
      t.decimal :revenue
      t.decimal :roi
      t.decimal :amount_ratio
      t.date    :event_date

      t.timestamps
    end

    add_index :adding_positions_histories, :origin_symbol
    add_index :adding_positions_histories, :event_date
  end
end
