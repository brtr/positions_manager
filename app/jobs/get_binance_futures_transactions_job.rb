class GetBinanceFuturesTransactionsJob < ApplicationJob
  queue_as :daily_job

  def perform(symbol)
    binance_data = BinanceFuturesService.new.get_my_trades(symbol)

    SyncedTransaction.transaction do
      binance_data.each do |d|
        revenue = d['realizedPnl'].to_f
        next if revenue == 0
        tx = SyncedTransaction.where(order_id: d['orderId']).first_or_create
        amount = d['quoteQty'].to_f + revenue
        tx.update(
          source: 'binance',
          origin_symbol: d['symbol'],
          fee_symbol: d['commissionAsset'],
          trade_type: d['side'].downcase,
          price: d['price'],
          qty: d['qty'],
          amount: amount,
          fee: d['commission'],
          revenue: revenue,
          event_time: Time.at(d['time'].to_i / 1000)
        )
      end
    end
  end
end
