class GetBinanceTradingDataService
  class << self
    def execute(symbol)
      redis_key = "#{symbol}_binance_trading_data"
      data = $redis.get(redis_key)
      if data.blank?
        binance_futures_service = BinanceFuturesService.new
        data = {
          open_interest: binance_futures_service.get_open_interest_hist(symbol),
          top_long_short_account_ratio: binance_futures_service.get_top_long_short_account_ratio(symbol),
          top_long_short_position_ratio: binance_futures_service.get_top_long_short_position_ratio(symbol),
          global_long_short_account_ratio: binance_futures_service.get_global_long_short_account_ratio(symbol),
          taker_long_short_ratio: binance_futures_service.get_taker_long_short_ratio(symbol)
        }.to_json

        $redis.set(redis_key, data, ex: 1.hour)
      end
      JSON.parse(data)
    end
  end
end