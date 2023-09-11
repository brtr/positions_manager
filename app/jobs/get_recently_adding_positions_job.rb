class GetRecentlyAddingPositionsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today, symbol: nil)
    event_time = symbol.present? ? date.all_day : (date - 1.day).all_day
    SyncedTransaction.where(user_id: nil, event_time: event_time).group_by{|tx| [tx.origin_symbol, tx.fee_symbol, tx.position_side, tx.trade_type, tx.source]}.each do |key, txs|
      origin_symbol = key[0]
      from_symbol = origin_symbol.split(key[1])[0]
      qty = txs.sum(&:qty)
      amount = txs.sum(&:amount)
      revenue = txs.sum(&:revenue)
      price = amount / qty
      trade_date = event_time.first.to_date
      trade_type = key[2] == 'short' ? 'buy' : 'sell'
      source = key[4]
      next if AddingPositionsHistory.where(event_date: trade_date - 1.day, origin_symbol: origin_symbol, qty: qty, amount: amount, trade_type: trade_type).any?

      aph = AddingPositionsHistory.where(event_date: trade_date, origin_symbol: origin_symbol, from_symbol: from_symbol, fee_symbol: key[1], qty: qty, trade_type: trade_type, source: source).first_or_create

      if trade_date == Date.today
        up = UserPosition.where(user_id: nil, origin_symbol: origin_symbol, trade_type: trade_type, source: source).take
        unit_cost = up&.price
        trading_roi = up&.roi
      else
        up = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {source_type: 'synced', user_id: nil, event_date: trade_date}, origin_symbol: origin_symbol, trade_type: trade_type, source: source).take
        cost_price = txs.sum(&:cost_price) / txs.count
        unit_cost = up&.price || cost_price
        trading_roi = up&.roi
      end

      current_price = get_current_price(source, origin_symbol)
      aph.update(price: price, current_price: current_price, amount: amount, revenue: revenue, unit_cost: unit_cost, trading_roi: trading_roi)
      SlackService.send_notification(nil, enqueued_block(from_symbol)) if AddingPositionsHistory.where("id != ? and event_date = ? and origin_symbol = ? and amount BETWEEN ? AND ?", aph.id, date, from_symbol, amount * 0.95, amount * 1.05).any?
    end
  end

  def get_current_price(source, symbol)
    if source == 'binance'
      BinanceFuturesService.new.get_ticker_price(symbol)["price"].to_f rescue 0
    else
      OkxSpotsService.new.get_price(symbol)["data"].first["last"] rescue 0
    end
  end

  def enqueued_block(origin_symbol)
    [
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*[Positions Manager]Sidekiq告警* 今天有重复生成的新增投入记录, 币种是 #{origin_symbol}"
        }
      }
    ]
  end
end
