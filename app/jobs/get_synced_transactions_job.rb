class GetSyncedTransactionsJob < ApplicationJob
  queue_as :daily_job

  def perform
    # Get Binance transactions
    UserPosition.where(user_id: nil, source: 'binance').each do |up|
      snapshot = up.last_snapshot
      next unless snapshot
      GetBinanceFuturesTransactionsJob.perform_later(up.origin_symbol) unless snapshot.qty == up.qty
    end

    # Get OKX transactions
    result = OkxFuturesService.get_orders

    SyncedTransaction.transaction do
      result['data'].each do |d|
        next if d['pnl'].to_f == 0 || d['category'] != 'normal'
        qty = get_contract_value(d['instId']) * d['accFillSz'].to_f
        price = d['avgPx'].to_f
        amount = qty * price
        SyncedTransaction.where(order_id: d['ordId']).first_or_create(
          source: 'okx',
          origin_symbol: d['instId'],
          fee_symbol: d['feeCcy'],
          trade_type: d['side'].downcase,
          price: price,
          qty: qty,
          amount: amount,
          fee: d['fee'].to_f.abs,
          revenue: d['pnl'],
          event_time: Time.at(d['cTime'].to_i / 1000)
        )
      end
    end
  end

  def get_contract_value(symbol)
    result = OkxFuturesService.get_contract_value(symbol)
    result["data"][0]["ctVal"].to_f rescue 1
  end
end
