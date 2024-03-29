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

  def self.total_summary(user_id=nil)
    records = user_id ? UserPosition.where(user_id: user_id) : UserPosition.where(user_id: nil)
    profit_records = records.select{|r| r.revenue > 0}
    loss_records = records.select{|r| r.revenue < 0}
    total_cost = records.sum(&:amount)
    new_total_funding_fee = FundingFeeHistory.where('user_id is null and event_date > ?', '2024-02-14').sum(&:amount) #统计2月14号清仓之后新的资金费用
    funding_rate = total_cost.zero? ? 0 : new_total_funding_fee.to_f / total_cost
    date = Date.yesterday
    infos = SnapshotInfo.includes(:snapshot_positions).where("event_date <= ?", date)
    {
      profit_count: profit_records.count,
      profit_amount: profit_records.sum(&:revenue),
      loss_count: loss_records.count,
      loss_amount: loss_records.sum(&:revenue),
      total_cost: total_cost,
      total_revenue: records.sum(&:revenue),
      total_funding_fee: FundingFeeHistory.where(user_id: nil).sum(&:amount),
      new_total_funding_fee: new_total_funding_fee,
      funding_rate: (funding_rate.abs * 100).round(2),
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
      min_roi_date: $redis.get("user_#{user_id}_#{date.to_s}_positions_min_roi_date"),
      max_profit_roi: infos.max_profit_roi(user_id: user_id),
      max_profit_roi_date: $redis.get("user_#{user_id}_#{date.to_s}_positions_max_profit_roi_date"),
      max_loss_roi: infos.max_loss_roi(user_id: user_id),
      max_loss_roi_date: $redis.get("user_#{user_id}_#{date.to_s}_positions_max_loss_roi_date"),
    }
  end

  def ranking
    CoinRanking.find_by(symbol: from_symbol.downcase)&.rank
  end

  def funding_fee
    FundingFeeHistory.where(user_id: user_id, origin_symbol: origin_symbol, trade_type: trade_type).sum(&:amount).round(4)
  end

  def last_funding_fee
    FundingFeeHistory.where(user_id: user_id, origin_symbol: origin_symbol, trade_type: trade_type).where('event_date < ?', Date.yesterday).sum(&:amount).round(4)
  end

  def notes
    user_positions_notes_histories.order(created_at: :asc).last&.notes
  end

  def images=(files=[])
    # TODO
  end

  def ranking_symbol
    "#{from_symbol}#{fee_symbol}"
  end

  def ranking_data
    JSON.parse($redis.get("get_bottom_24hr_tickers")).select{|x| x['symbol'] == ranking_symbol}.first rescue nil
  end

  def risen_ratio
    ranking_data&.fetch('risenRatio')
  end

  def top_price_ratio
    ranking_data&.fetch('topPriceRatio')
  end

  def adding_positions_histories
    AddingPositionsHistory.where('current_price is not null and (amount > ? or amount < ?) and origin_symbol = ? and source = ? and trade_type = ?', 1, -1, origin_symbol, source, trade_type)
  end

  def closing_histories
    adding_positions_histories.closing_data
  end

  def closing_revenue
    redis_key = "user_positions_closing_revenue_#{origin_symbol}_#{trade_type}_#{source}_#{user_id}"
    temp_revenue = $redis.get(redis_key).to_f
    if temp_revenue == 0
      temp_revenue = closing_histories.sum(&:get_revenue)
      $redis.set(redis_key, temp_revenue, ex: 1.hours)
    end

    temp_revenue.to_f
  end

  def closing_roi
    redis_key = "user_positions_closing_roi_#{origin_symbol}_#{trade_type}_#{source}_#{user_id}"
    temp_roi = $redis.get(redis_key).to_f
    if temp_roi == 0
      amount = closing_histories.sum{|h| h.amount.abs}
      temp_roi = amount == 0 ? 0 : ((closing_revenue.to_f / (amount + closing_revenue.to_f)) * 100).round(3)
      $redis.set(redis_key, temp_roi, ex: 1.hours)
    end

    temp_roi.to_f
  end

  def average_durations
    redis_key = "user_positions_duration_#{origin_symbol}_#{trade_type}_#{source}_#{user_id}"
    duration = $redis.get(redis_key).to_f
    if duration == 0
      duration = adding_positions_histories.average_holding_duration
      $redis.set(redis_key, duration, ex: 1.hours)
    end

    duration.to_f
  end

end
