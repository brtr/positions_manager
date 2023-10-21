class CreateBinancePositions < ActiveRecord::Migration[6.1]
  def change
    create_table :binance_positions do |t|
      t.string  :symbol
      t.decimal :price

      t.timestamps
    end
  end
end
