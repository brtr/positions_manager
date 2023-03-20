class RankingSnapshot < ApplicationRecord
  scope :with_top10, ->(source, symbol) { where(is_top10: true, source: source, symbol: symbol) }
  def self.get_rankings
    RankingSnapshot.order(event_date: :asc).group_by{|snapshot| [snapshot.symbol, snapshot.source]}.map do |key, data|
      open_price = data.first.open_price
      last_record = data.last
      last_price = last_record.last_price
      price_change = (last_price - open_price) / open_price rescue 0
      {
        "symbol" => key[0],
        "lastPrice" => last_price,
        "priceChangePercent" => (price_change * 100).round(3).to_s,
        "bottomPriceRatio" => last_record.bottom_price_ratio.to_s,
        "source" => key[1]
      }
    end
  end
end
