class AddingPositionsHistory < ApplicationRecord
  def revenue
    last_amount = qty.abs * current_price
    trade_type == 'sell' ? last_amount - amount.abs : amount.abs - last_amount
  end

  def roi
    ((revenue / amount.abs) * 100).round(3)
  end

  def amount_ratio
    up = UserPosition.find_by(user_id: nil, origin_symbol: origin_symbol, source: source, trade_type: trade_type)

    if up.present? && up.qty != 0
      "#{((amount / up.amount) * 100).round(3)}%"
    else
      'N/A'
    end
  end
end
