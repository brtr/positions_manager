class GetSyncedTransactionsJob < ApplicationJob
  queue_as :daily_job

  def perform
    # Get Binance transactions
    binance_symbols = UserPosition.where(user_id: nil, source: 'binance').pluck(:origin_symbol)
    binance_symbols += SnapshotPosition.joins(:snapshot_info).where(source: 'binance',
                       snapshot_info: {source_type: 'synced', user_id: nil, event_date: Date.yesterday}).pluck(:origin_symbol)

    binance_symbols.uniq.each do |symbol|
      GetBinanceFuturesTransactionsJob.perform_later(symbol)
    end

    # Get OKX transactions
    result = OkxFuturesService.get_orders

    SyncedTransaction.transaction do
      result['data'].each do |d|
        next if d['category'] != 'normal'
        qty = get_contract_value(d['instId']) * d['accFillSz'].to_f
        price = d['avgPx'].to_f
        amount = qty * price
        revenue = d['pnl'].to_f
        trade_type = d['side'].downcase
        position_side = if trade_type == 'sell'
                          revenue == 0 ? 'short' : 'long'
                        else
                          revenue == 0 ? 'long' : 'short'
                        end
        tx = SyncedTransaction.where(order_id: d['ordId']).first_or_create
        tx.update(
          source: 'okx',
          origin_symbol: d['instId'],
          fee_symbol: d['feeCcy'],
          trade_type: trade_type,
          price: price,
          qty: get_number(qty, revenue),
          amount: get_number(amount, revenue),
          fee: d['fee'].to_f.abs,
          revenue: revenue,
          position_side: position_side,
          event_time: Time.at(d['cTime'].to_i / 1000)
        )
      end
    end
  end

  def get_contract_value(symbol)
    result = OkxFuturesService.get_contract_value(symbol)
    result["data"][0]["ctVal"].to_f rescue 1
  end

  def get_number(num, revenue)
    revenue == 0 || num == 0 ? num : num * -1
  end
end
