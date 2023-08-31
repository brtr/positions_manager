class CreateWalletHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :wallet_histories do |t|
      t.integer  :user_id
      t.integer  :trade_type
      t.integer  :transfer_type
      t.string   :order_no
      t.string   :network
      t.string   :symbol
      t.boolean  :is_completed
      t.decimal  :amount, default: 0
      t.decimal  :fee, default: 0
      t.datetime :apply_time
      t.datetime :complete_time

      t.timestamps
    end

    add_index :wallet_histories, :user_id
    add_index :wallet_histories, :trade_type
    add_index :wallet_histories, :is_completed
    add_index :wallet_histories, :transfer_type
    add_index :wallet_histories, :order_no
  end
end
