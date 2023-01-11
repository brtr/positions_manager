class GetBinanceFuturesTransactionsJob < ApplicationJob
  queue_as :daily_job

  def perform(symbol)
    binance_data = BinanceFuturesService.new.get_my_trades(symbol)

    SyncedTransaction.transaction do
      binance_data.each do |d|
        SyncedTransaction.where(order_id: d['orderId']).first_or_create(
          source: 'binance',
          origin_symbol: d['symbol'],
          fee_symbol: d['commissionAsset'],
          trade_type: d['side'].downcase,
          price: d['price'],
          qty: d['qty'],
          amount: d['quoteQty'],
          fee: d['commission'],
          revenue: d['realizedPnl'],
          event_time: Time.at(d['time'].to_i / 1000)
        )
      end
    end
  end
end
