require 'openssl'
require 'rest-client'

class SyncFuturesTickerService
  class << self
    def get_24hr_tickers(rank)
      binance_24hr_tickers = BinanceFuturesService.new.get_24hr_tickers
      okx_24hr_tickers = OkxFuturesService.get_24hr_tickers

      binance_24hr_tickers.map! do |ticker|
        next if Time.at(ticker["closeTime"].to_f / 1000) < Date.today
        next if ticker["symbol"] == "BTCDOMUSDT"
        last_price = ticker["lastPrice"].to_f
        from_symbol = fetch_symbol(ticker["symbol"])
        price_ratio = get_price_ratio(from_symbol, last_price, rank)
        {
          "symbol" => ticker["symbol"],
          "lastPrice" => last_price,
          "priceChangePercent" => ticker["priceChangePercent"],
          "bottomPriceRatio" => price_ratio['bottom_ratio'].to_s,
          "risenRatio" => price_ratio['risen_ratio'],
          "topPriceRatio" => price_ratio['top_ratio'],
          "openPrice" => ticker["openPrice"],
          "source" => "binance"
        }
      end

      okx_24hr_tickers.map! do |ticker|
        next if Time.at(ticker["ts"].to_f / 1000) < Date.today
        from_symbol, to_symbol = ticker["instId"].split(/-/)
        open_price = ticker["sodUtc8"].to_f
        last_price = ticker["last"].to_f
        price_change = (ticker["last"].to_f - open_price) / open_price
        price_ratio = get_price_ratio(from_symbol, last_price, rank)
        {
          "symbol" => from_symbol + to_symbol,
          "lastPrice" => last_price,
          "priceChangePercent" => (price_change * 100).round(3).to_s,
          "bottomPriceRatio" => price_ratio['bottom_ratio'].to_s,
          "risenRatio" => price_ratio['risen_ratio'],
          "topPriceRatio" => price_ratio['top_ratio'],
          "openPrice" => open_price,
          "source" => "okx"
        }
      end

      result = (binance_24hr_tickers + okx_24hr_tickers).group_by do |d|
        next if d.blank?
        symbol = d["symbol"]
        from_symbol = symbol.split(/USDT/)[0]
        from_symbol = symbol.split(/BUSD/)[0] if from_symbol == symbol
        from_symbol = symbol.split(/USD/)[0] if from_symbol == symbol
        from_symbol
      end.map{|k,v| v[0]}.compact

      $redis.set("get_24hr_tickers", result.to_json)
    end

    private

    def fetch_symbol(symbol)
      from_symbol = symbol
      fee_symbols = %w[BUSD USDT USD]
      fee_symbols.each do |fee_symbol|
        from_symbol = symbol.split(fee_symbol)[0]
        if from_symbol != symbol
          break
          return from_symbol
        end
      end
      from_symbol
    end

    def get_price_ratio(symbol, price, rank)
      url = ENV['COIN_ELITE_URL'] + "/api/user_positions/get_price_ratio?symbol=#{symbol}&price=#{price}"
      url += "&rank=#{rank}" if rank > 0
      response = RestClient.get(url)
      data = JSON.parse(response)
      data
    end
  end
end