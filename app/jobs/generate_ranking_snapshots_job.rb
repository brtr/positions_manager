class GenerateRankingSnapshotsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    RankingSnapshot.transaction do
      data = JSON.parse($redis.get("get_24hr_tickers")) rescue []
      data.each do |d|
        snapshot = RankingSnapshot.where(event_date: date, symbol: d["symbol"]).first_or_create
        snapshot.update(source: d["source"], open_price: d["openPrice"], last_price: d["lastPrice"],
                        price_change_rate: d["priceChangePercent"], bottom_price_ratio: d["bottomPriceRatio"])
      end
    end
  end
end
