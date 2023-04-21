class GetRecentlyAddingPositionsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    SyncedTransaction.where(user_id: nil, event_time: (date - 1.day).all_day).group_by{|tx| [tx.origin_symbol, tx.fee_symbol, tx.position_side, tx.source]}.each do |key, txs|
      from_symbol = key[0].split(key[1])[0]
      trade_type = key[2] == 'short' ? 'buy' : 'sell'
      qty = txs.sum(&:qty)
      amount = txs.sum(&:amount)
      revenue = txs.sum(&:revenue)
      price = amount / qty
      unless AddingPositionsHistory.exists?(event_date: date - 1.day, origin_symbol: key[0], qty: qty, amount: amount, price: price)
        aph = AddingPositionsHistory.where(event_date: date, origin_symbol: key[0], from_symbol: from_symbol,
                                          fee_symbol: key[1], trade_type: trade_type, source: key[3]).first_or_create
        up = UserPosition.where(user_id: nil, origin_symbol: key[0], trade_type: trade_type, source: key[3]).take
        unit_cost = up&.price || get_last_price(key[0], date)
        current_price = up&.current_price || get_history_price(from_symbol.downcase, date)
        aph.update(price: price, current_price: current_price, qty: qty, amount: amount, revenue: revenue, unit_cost: unit_cost)
      end
    end
  end

  def get_last_price(symbol, event_date)
    snapshot = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {source_type: 'synced', user_id: nil, event_date: event_date - 1.day}, origin_symbol: symbol).take
    snapshot&.price
  end

  def get_history_price(symbol, event_date)
    date = event_date == Date.today ? event_date - 1.day : event_date
    url = ENV['COIN_ELITE_URL'] + "/api/coins/history_price?symbol=#{symbol}&from_date=#{date}&to_date=#{date}"
    response = RestClient.get(url)
    data = JSON.parse(response.body)
    data['result'].values[0].to_f rescue nil
  end
end
