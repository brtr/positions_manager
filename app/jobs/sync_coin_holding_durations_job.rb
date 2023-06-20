class SyncCoinHoldingDurationsJob < ApplicationJob
  queue_as :daily_job

  def perform
    # 检查有没有新增仓位
    UserPosition.where.not(qty: 0).each do |up|
      chd = CoinHoldingDuration.where(symbol: up.origin_symbol, source: up.source, duration: 0, trade_type: up.trade_type, user_id: up.user_id).first_or_create
      next if chd.start_trading_at.present? && chd.duration.zero?
      chd.update(start_trading_at: Time.current)
    end

    # 检查清仓的仓位
    UserPosition.where(qty: 0).each do |up|
      chd = CoinHoldingDuration.where(symbol: up.origin_symbol, source: up.source, duration: 0, trade_type: up.trade_type, user_id: up.user_id).first
      next if chd.nil? || chd.start_trading_at.nil?
      duration = Time.current - chd.start_trading_at
      chd.update(duration: duration)
    end

    ForceGcJob.perform_later
  end
end
