class UserPosition < ApplicationRecord
  LEVEL = %w[弱 中 强 最强 大资金长期关注]

  belongs_to :user, optional: true
  has_many :user_positions_notes_histories

  scope :available, -> { where("qty > 0") }

  enum source: [:binance, :okx, :huobi]

  def amount
    qty * price
  end

  def revenue
    if trade_type == "sell"
      current_price.to_f * qty - amount
    else
      amount - current_price.to_f * qty
    end
  end

  def roi
    revenue / amount
  end

  def cost_ratio(total_cost)
    amount / total_cost
  end

  def revenue_ratio(total_revenue)
    ratio = (revenue / total_revenue).abs
    revenue > 0 ? ratio : ratio * -1
  end

  def margin_revenue
    compare_revenue = $redis.get("user_positions_#{id}_compare_revenue").to_f
    (revenue - compare_revenue).round(4) rescue 0
  end

  def last_snapshot
    SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {source_type: 'synced', user_id: nil, event_date: Date.yesterday},
                                                 origin_symbol: origin_symbol, trade_type: trade_type, source: source).take
  end

  def average_durations
    redis_key = "user_positions_duration_#{origin_symbol}_#{trade_type}_#{source}_#{user_id}"
    duration = $redis.get(redis_key).to_f
    if duration == 0
      duration = AddingPositionsHistory.where('current_price is not null and (amount > ? or amount < ?) and origin_symbol = ? and source = ? and trade_type = ?', 1, -1, origin_symbol, source, trade_type).average_holding_duration
      $redis.set(redis_key, duration, ex: 2.hours)
    end

    duration.to_f
  end

  def self.total_summary(user_id=nil)
    records = user_id ? UserPosition.where(user_id: user_id) : UserPosition.where(user_id: nil)
    profit_records = records.select{|r| r.revenue > 0}
    loss_records = records.select{|r| r.revenue < 0}
    date = Date.yesterday
    infos = SnapshotInfo.includes(:snapshot_positions).where("event_date <= ?", date)
    {
      profit_count: profit_records.count,
      profit_amount: profit_records.sum(&:revenue),
      loss_count: loss_records.count,
      loss_amount: loss_records.sum(&:revenue),
      total_cost: records.sum(&:amount),
      total_revenue: records.sum(&:revenue),
      total_funding_fee: FundingFeeHistory.where(user_id: nil).sum(&:amount),
      max_profit: infos.max_profit(user_id: user_id),
      max_profit_date: $redis.get("user_#{user_id}_#{date.to_s}_positions_max_profit_date"),
      max_loss: infos.max_loss(user_id: user_id),
      max_loss_date: $redis.get("user_#{user_id}_#{date.to_s}_positions_max_loss_date"),
      max_revenue: infos.max_revenue(user_id: user_id),
      max_revenue_date: $redis.get("user_#{user_id}_#{date.to_s}_positions_max_revenue_date"),
      min_revenue: infos.min_revenue(user_id: user_id),
      min_revenue_date: $redis.get("user_#{user_id}_#{date.to_s}_positions_min_revenue_date"),
      max_roi: infos.max_roi(user_id: user_id),
      max_roi_date: $redis.get("user_#{user_id}_#{date.to_s}_positions_max_roi_date"),
      min_roi: infos.min_roi(user_id: user_id),
      min_roi_date: $redis.get("user_#{user_id}_#{date.to_s}_positions_min_roi_date")
    }
  end

  def ranking
    CoinRanking.find_by(symbol: from_symbol.downcase)&.rank
  end

  def funding_fee
    FundingFeeHistory.where(user_id: user_id, origin_symbol: origin_symbol).sum(&:amount).round(4)
  end

  def last_funding_fee
    FundingFeeHistory.where(user_id: user_id, origin_symbol: origin_symbol).where('event_date < ?', Date.yesterday).sum(&:amount).round(4)
  end

  def notes
    user_positions_notes_histories.order(created_at: :asc).last&.notes
  end

  def images=(files=[])
    # TODO
  end

end
