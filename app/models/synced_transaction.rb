class SyncedTransaction < ApplicationRecord
  scope :available, -> { where.not(revenue: 0) }

  def self.total_summary(user_id: nil)
    records = SyncedTransaction.available.where(user_id: user_id)
    profit_records = records.select{|r| r.revenue > 0}
    loss_records = records.select{|r| r.revenue < 0}
    {
      profit_count: profit_records.count,
      profit_amount: profit_records.sum(&:revenue),
      loss_count: loss_records.count,
      loss_amount: loss_records.sum(&:revenue),
      total_cost: records.sum(&:total_cost),
      total_revenue: records.sum(&:revenue),
      total_fee: records.sum(&:fee)
    }
  end

  def roi
    revenue / amount.abs
  end

  def cost_price
    total_cost / qty.abs
  end

  def total_cost
    position_side == 'long' ? amount.abs - revenue : amount.abs + revenue
  end

  def target_position
    convert_trade_type = position_side == 'long' ? 'sell' : 'buy'
    UserPosition.find_by(user_id: nil, origin_symbol: origin_symbol, source: source, trade_type: convert_trade_type)
  end

  def current_price
    target_position&.current_price
  end

  def estimate_revenue
    return 0 if current_price.nil?
    position_side == 'long' ? current_price * qty - total_cost : total_cost - current_price * qty
  end
end
