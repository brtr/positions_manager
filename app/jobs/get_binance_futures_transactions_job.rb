class GetBinanceFuturesTransactionsJob < ApplicationJob
  queue_as :daily_job

  def perform(symbol)
    binance_data = BinanceFuturesService.new.get_my_trades(symbol)

    SyncedTransaction.transaction do
      binance_data.each do |d|
        revenue = d['realizedPnl'].to_f
        amount = d['quoteQty'].to_f
        trade_type = d['side'].downcase
        position_side = if trade_type == 'sell'
                          revenue == 0 ? 'short' : 'long'
                        else
                          revenue == 0 ? 'long' : 'short'
                        end
        tx = SyncedTransaction.where(order_id: d['id']).first_or_create
        tx.update(
          source: 'binance',
          origin_symbol: d['symbol'],
          fee_symbol: d['commissionAsset'],
          trade_type: trade_type,
          price: d['price'],
          qty: get_number(d['qty'].to_f, revenue),
          amount: get_number(amount, revenue),
          fee: d['commission'],
          revenue: revenue,
          position_side: position_side,
          event_time: Time.at(d['time'].to_i / 1000)
        )
      end
    end
  end

  def get_number(num, revenue)
    revenue == 0 || num == 0 ? num : num * -1
  end
end
