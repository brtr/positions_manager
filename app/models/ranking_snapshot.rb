class RankingSnapshot < ApplicationRecord
  scope :with_top10, ->(source, symbol) { where(is_top10: true, source: source, symbol: symbol) }

  def self.get_daily_rankings
    RankingSnapshot.order(event_date: :asc).group_by{|snapshot| [snapshot.symbol, snapshot.source]}.map do |key, data|
      open_price = data.first.open_price
      last_record = data.last
      last_price = last_record.last_price
      price_change = (last_price - open_price) / open_price rescue 0
      {
        "symbol" => key[0],
        "lastPrice" => last_price,
        "priceChangePercent" => (price_change * 100).round(4).to_s,
        "bottomPriceRatio" => last_record.bottom_price_ratio.to_s,
        "source" => key[1]
      }
    end
  end

  def self.get_rankings(duration: 12, rank: nil, data_type: nil, source: nil)
    if data_type == 'weekly'
      duration_key = 'weekly_duration'
      rank_key = 'weekly_select'
      redis_key = "get_one_week_tickers_#{duration}_#{rank}_#{source}"
    else
      duration_key = 'three_days_duration'
      rank_key = 'three_days_select'
      redis_key = "get_three_days_tickers_#{duration}_#{rank}_#{source}"
    end

    $redis.set(duration_key, duration)
    $redis.set(rank_key, rank)

    result = JSON.parse($redis.get(redis_key)) rescue nil
    if result.nil?
      result = RankingSnapshot.order(event_date: :asc).group_by{|snapshot| [snapshot.symbol, snapshot.source]}.map do |key, data|
        open_price = data.first.open_price
        last_price =  data.last.last_price
        price_ratio = nil

        max_retries = 3
        retries = 0
        while price_ratio.nil? && retries < max_retries
          price_ratio = get_price_ratio(fetch_symbol(key[0]), last_price, rank, duration)
          retries += 1
          sleep(1)
        end

        price_change = (last_price - open_price) / open_price rescue 0
        {
          "symbol" => key[0],
          "lastPrice" => last_price,
          "priceChangePercent" => (price_change * 100).round(4).to_s,
          "bottomPriceRatio" => (price_ratio['bottom_ratio'].to_s rescue ''),
          "topPriceRatio" => (price_ratio['top_ratio'].to_s rescue ''),
          "source" => key[1]
        }
      end

      $redis.set(redis_key, result.to_json, ex: 12.hour)
    end

    result
  end

  private

  def self.fetch_symbol(symbol)
    SyncFuturesTickerService.fetch_symbol(symbol)
  end

  def self.get_price_ratio(symbol, price, rank, duration)
    redis_key = "get_price_ratio_#{symbol}_#{price}_#{rank}_#{duration}"
    price_ratio = JSON.parse($redis.get(redis_key)) rescue nil

    if price_ratio.nil?
      data = SyncFuturesTickerService.get_price_ratio(symbol, price, rank, duration)

      $redis.set(redis_key, data.to_json, ex: 12.hour)
    end

    price_ratio
  end
end
