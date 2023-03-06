class GenerateRankingSnapshotsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    RankingSnapshot.transaction do
      data = JSON.parse($redis.get("get_24hr_tickers")) rescue []
      data.sort_by{|d| d["priceChangePercent"].to_f}.reverse.each_with_index do |d, idx|
        snapshot = RankingSnapshot.where(event_date: date, symbol: d["symbol"], source: d["source"]).first_or_create
        is_top10 = idx < 10 && d["priceChangePercent"].to_f > 10
        snapshot.update(open_price: d["openPrice"], last_price: d["lastPrice"], is_top10: is_top10,
                        price_change_rate: d["priceChangePercent"], bottom_price_ratio: d["bottomPriceRatio"])
      end
    end
  end
end
