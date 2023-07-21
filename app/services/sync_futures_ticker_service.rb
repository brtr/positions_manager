require 'openssl'
require 'rest-client'

class SyncFuturesTickerService
  SYMBOLS = %w[USDCUSDT BTCDOMUSDT USTCUSDT]
  class << self
    def get_24hr_tickers(bottom_select, top_select, duration, data_type)
      binance_24hr_tickers = BinanceFuturesService.new.get_24hr_tickers
      okx_24hr_tickers = OkxFuturesService.new.get_24hr_tickers
      if bottom_select.to_i > 0
        rank = bottom_select
        price_type = 'bottom'
      else
        rank = top_select
        price_type = 'top'
      end

      binance_24hr_tickers.map! do |ticker|
        next if Time.at(ticker["closeTime"].to_f / 1000) < Date.today
        open_price = ticker["openPrice"].to_f
        last_price = ticker["lastPrice"].to_f
        margin = ticker["highPrice"].to_f - ticker["lowPrice"].to_f
        from_symbol = fetch_symbol(ticker["symbol"])
        price_ratio = get_price_ratio(from_symbol, last_price, rank, price_type, duration)
        {
          "symbol" => ticker["symbol"],
          "lastPrice" => last_price,
          "priceChangePercent" => ticker["priceChangePercent"],
          "bottomPriceRatio" => price_ratio['bottom_ratio'].to_s,
          "risenRatio" => price_ratio['risen_ratio'],
          "topPriceRatio" => price_ratio['top_ratio'],
          "openPrice" => open_price,
          "amplitude" => get_amplitude(open_price, margin),
          "source" => "binance"
        }
      end

      okx_24hr_tickers.map! do |ticker|
        next if Time.at(ticker["ts"].to_f / 1000) < Date.today
        from_symbol, to_symbol = ticker["instId"].split(/-/)
        open_price = ticker["sodUtc8"].to_f
        last_price = ticker["last"].to_f
        margin = ticker["high24h"].to_f - ticker["low24h"].to_f
        price_change = (ticker["last"].to_f - open_price) / open_price
        price_ratio = get_price_ratio(from_symbol, last_price, rank, price_type, duration)
        {
          "symbol" => from_symbol + to_symbol,
          "lastPrice" => last_price,
          "priceChangePercent" => (price_change * 100).round(4).to_s,
          "bottomPriceRatio" => price_ratio['bottom_ratio'].to_s,
          "risenRatio" => price_ratio['risen_ratio'],
          "topPriceRatio" => price_ratio['top_ratio'],
          "openPrice" => open_price,
          "amplitude" => get_amplitude(open_price, margin),
          "source" => "okx"
        }
      end

      result = (binance_24hr_tickers + okx_24hr_tickers).group_by do |d|
        next if d.blank?
        symbol = d["symbol"]
        next if symbol.in?(SYMBOLS)
        next if symbol.match(/1000/)
        next unless symbol.match(/.*(?:USDT|BUSD).*/) # 排除非BUSD 和 USDT 的货币对
        from_symbol = symbol.split(/USDT/)[0]
        from_symbol = symbol.split(/BUSD/)[0] if from_symbol == symbol
        from_symbol = symbol.split(/USD/)[0] if from_symbol == symbol
        from_symbol
      end.map{|k,v| v[0]}.compact

      redis_key = if data_type == 'bottom'
                    'get_bottom_24hr_tickers'
                  elsif data_type == 'top'
                    'get_top_24hr_tickers'
                  else
                    'get_24hr_tickers'
                  end

      $redis.set(redis_key, result.to_json)
    end

    def fetch_symbol(symbol)
      from_symbol = symbol
      fee_symbols = %w[USDT BUSD USD]
      fee_symbols.each do |fee_symbol|
        from_symbol = symbol.split(fee_symbol)[0]
        if from_symbol != symbol
          break
          return from_symbol
        end
      end
      from_symbol
    end

    private

    def get_price_ratio(symbol, price, rank, price_type, duration)
      url = ENV['COIN_ELITE_URL'] + "/api/user_positions/get_price_ratio?symbol=#{symbol}&price=#{price}&duration=#{duration}"
      url += "&rank=#{rank}&price_type=#{price_type}" if rank.to_i > 0
      response = RestClient.get(url)
      data = JSON.parse(response)
      data
    end

    def get_amplitude(open_price, margin)
      ((margin / open_price) * 100).round(4) rescue 0
    end
  end
end