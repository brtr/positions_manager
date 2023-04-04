class GetRankingChartDataService
  class << self
    def execute(symbol, source)
      to_date = Date.today
      from_date = to_date - 3.month

      result = {}
      RankingSnapshot.where(symbol: symbol, source: source, event_date: (from_date..to_date)).order(event_date: :asc)
                     .map{|s| result[s.event_date] = {rate: s.price_change_rate.to_f, is_top10: (s.is_top10 ? 1 : 0), date: s.event_date}}

      adding_positions_histories = AddingPositionsHistory.where(origin_symbol: symbol, source: source, event_date: (from_date..to_date)).order(event_date: :asc)
                                                         .group_by(&:event_date)

      adding_positions_histories.each do |date, histories|
        qty = histories.sum(&:qty).round(4)
        price = qty == 0 ? 0 : (histories.sum(&:amount) / qty).round(4)
        if result[date].present?
          result[date].merge!({price: price, qty: qty})
        else
          result[date] = {price: price, qty: qty, date: date}
        end
      end

      result.sort_by{|k,v| k}.to_h
    end
  end
end