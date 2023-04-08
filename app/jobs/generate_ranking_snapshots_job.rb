class GenerateRankingSnapshotsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    # 开始数据库事务
    RankingSnapshot.transaction do
      # 从 Redis 中获取数据
      tickers = JSON.parse($redis.get("get_24hr_tickers")) rescue []

      # 根据价格变化率排序并处理每个元素
      tickers.sort_by { |ticker| -ticker["priceChangePercent"].to_f }.each_with_index do |ticker, idx|
        # 查找或创建快照记录
        ranking_snapshot = RankingSnapshot.find_or_initialize_by(event_date: date, symbol: ticker["symbol"], source: ticker["source"])

        # 更新快照记录
        is_top10 = idx < 10 && ticker["priceChangePercent"].to_f > 10
        price_change_percent = ticker["priceChangePercent"].to_f
        ranking_snapshot.update(
          open_price: ticker["openPrice"],
          last_price: ticker["lastPrice"],
          is_top10: is_top10,
          price_change_rate: price_change_percent,
          bottom_price_ratio: ticker["bottomPriceRatio"]
        )
      end
    end

    # 触发垃圾回收任务
    ForceGcJob.perform_later
  end
end
