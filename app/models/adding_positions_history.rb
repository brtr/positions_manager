class AddingPositionsHistory < ApplicationRecord
  def revenue
    last_amount = qty.abs * current_price
    trade_type == 'sell' ? last_amount - amount.abs : amount.abs - last_amount
  end

  def roi
    ((revenue / amount.abs) * 100).round(3)
  end

  def amount_ratio
    if target_position.present? && target_position.qty != 0
      "#{((amount / target_position.amount) * 100).round(3)}%"
    else
      'N/A'
    end
  end

  def target_position
    UserPosition.find_by(user_id: nil, origin_symbol: origin_symbol, source: source, trade_type: trade_type)
  end

  def self.total_qty
    AddingPositionsHistory.sum(&:qty)
  end

  def self.total_amount
    AddingPositionsHistory.sum(&:amount)
  end

  def self.total_revenue(current_price, trade_type)
    last_amount = total_qty.abs * current_price
    trade_type == 'sell' ? last_amount - total_amount.abs : total_amount.abs - last_amount
  end

  def self.amount_ratio(up)
    if up.present? && up.qty != 0
      "#{((total_amount / up.amount) * 100).round(3)}%"
    else
      'N/A'
    end
  end

end
