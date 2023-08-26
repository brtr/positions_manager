class AddingPositionsHistory < ApplicationRecord
  def get_revenue
    return revenue.to_f if qty < 0
    last_amount = qty.abs * current_price
    trade_type == 'sell' ? last_amount - amount.abs : amount.abs - last_amount
  end

  def roi
    ((get_revenue / (amount.abs + get_revenue)) * 100).round(4)
  end

  def amount_ratio
    if target_position.present? && target_position.qty != 0
      "#{((amount / target_position.amount) * 100).round(4)}%"
    else
      'N/A'
    end
  end

  def target_position
    UserPosition.find_by(user_id: nil, origin_symbol: origin_symbol, source: source, trade_type: trade_type)
  end

  def cost
    trade_type == 'buy' ? (amount.abs + revenue.to_f) / qty.abs : (amount.abs - revenue.to_f) / qty.abs
  end

  def holding_duration
    return 0 if qty < 0
    Time.current - event_date.to_time
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
      "#{((total_amount / up.amount) * 100).round(4)}%"
    else
      'N/A'
    end
  end

  def self.average_holding_duration
    data = AddingPositionsHistory.where('qty > 0')
    return 0 if data.blank?
    data.sum(&:holding_duration) / data.count
  end
end
