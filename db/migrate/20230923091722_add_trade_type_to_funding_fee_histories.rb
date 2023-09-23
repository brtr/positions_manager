class AddTradeTypeToFundingFeeHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :funding_fee_histories, :trade_type, :string
  end
end
