class AddingPositionsHistory < ApplicationRecord
  scope :available, -> { where('current_price is not null and (amount > ? or amount < ?)', 1, -1) }
  scope :closing_data, -> { where('qty < 0') }

  def get_revenue
    return revenue.to_f + trading_fee if qty < 0
    last_amount = qty.abs * current_price
    trade_type == 'sell' ? last_amount - amount.abs : amount.abs - last_amount
  end

  def roi
    adding_amount = if qty < 0
                      trade_type == 'sell' ? total_cost.abs + get_revenue : total_cost.abs
                    else
                      trade_type == 'sell' ? amount.abs + get_revenue : amount.abs
                    end
    ((get_revenue / adding_amount) * 100).round(4)
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

  def total_cost
    unit_cost.to_f * qty.abs
  end

  def holding_duration
    return 0 if qty < 0
    Time.current - event_date.to_time
  end

  def trading_fee
    fee = $redis.get("aph_#{id}_trading_fee")
    if fee.nil?
      if snapshot_position.present?
        fee = FundingFeeHistory.where('user_id is null and origin_symbol = ? and event_date <= ? and trade_type = ?', origin_symbol, event_date - 1.day, trade_type).sum(&:amount) * (amount / snapshot_position.amount)
      else
        fee = 0
      end

      $redis.set("aph_#{id}_trading_fee", fee, ex: 5.hours)
    end

    fee.to_f
  end

  def snapshot_position
    SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {user_id: nil, event_date: event_date - 1.day}, origin_symbol: origin_symbol, source: source, trade_type: trade_type).take
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

  def self.total_summary
    records = AddingPositionsHistory.closing_data
    profit_records = records.select{|r| r.get_revenue > 0}
    loss_records = records.select{|r| r.get_revenue < 0}
    date = Date.yesterday
    total_amount = records.sum{|x| x.amount.abs}
    total_revenue = records.sum(&:get_revenue)
    infos = ClosingHistoriesSnapshotInfo.includes(:closing_histories_snapshot_records).where("event_date <= ?", date)
    {
      profit_count: profit_records.count,
      profit_amount: profit_records.sum(&:get_revenue),
      loss_count: loss_records.count,
      loss_amount: loss_records.sum(&:get_revenue),
      total_cost: total_revenue + total_amount,
      total_revenue: total_revenue,
      max_profit: infos.max_profit,
      max_profit_date: $redis.get("#{date.to_s}_closing_histories_max_profit_date"),
      max_loss: infos.max_loss,
      max_loss_date: $redis.get("#{date.to_s}_closing_histories_max_loss_date"),
      max_revenue: infos.max_revenue,
      max_revenue_date: $redis.get("#{date.to_s}_closing_histories_max_revenue_date"),
      min_revenue: infos.min_revenue,
      min_revenue_date: $redis.get("#{date.to_s}_closing_histories_min_revenue_date"),
      max_roi: infos.max_roi,
      max_roi_date: $redis.get("#{date.to_s}_closing_histories_max_roi_date"),
      min_roi: infos.min_roi,
      min_roi_date: $redis.get("#{date.to_s}_closing_histories_min_roi_date")
    }
  end
end
