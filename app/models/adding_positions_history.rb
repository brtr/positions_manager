class AddingPositionsHistory < ApplicationRecord
  def revenue
    last_amount = qty.abs * current_price
    trade_type == 'sell' ? last_amount - amount.abs : amount.abs - last_amount
  end

  def roi
    ((revenue / amount.abs) * 100).round(3)
  end
end
