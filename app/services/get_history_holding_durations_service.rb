class GetHistoryHoldingDurationsService
  class << self
    def execute
      SyncedTransaction.order(event_time: :asc).each do |tx|
        if tx.revenue.zero?
          chd = CoinHoldingDuration.where(user_id: tx.user_id, source: tx.source, symbol: tx.origin_symbol, duration: 0).first_or_create
          chd.update(start_trading_at: tx.event_time) if chd.start_trading_at.nil?
          chd.update(qty: chd.qty + tx.qty.abs)
        else
          chd = CoinHoldingDuration.where(user_id: tx.user_id, source: tx.source, symbol: tx.origin_symbol, duration: 0).first
          next if chd.nil? || chd.start_trading_at.nil?
          chd.update(qty: chd.qty - tx.qty.abs)
          if chd.qty.zero?
            duration = tx.event_time - chd.start_trading_at
            chd.update(duration: duration)
          end
        end
      end
    end
  end
end
