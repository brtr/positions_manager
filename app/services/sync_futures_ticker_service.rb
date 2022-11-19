require 'openssl'
require 'rest-client'

class SyncFuturesTickerService
  class << self
    def get_24hr_tickers
      binance_24hr_tickers = BinanceFuturesService.get_24hr_tickers
      okx_24hr_tickers = OkxFuturesService.get_24hr_tickers

      binance_24hr_tickers.map! do |ticker|
        from_symbol = fetch_symbol(ticker["symbol"])
        {
          "symbol" => ticker["symbol"],
          "lastPrice" => ticker["lastPrice"],
          "priceChangePercent" => ticker["priceChangePercent"],
          "bottomPriceRatio" => get_bottom_price_ratio(from_symbol, ticker["lastPrice"].to_f).to_s
        }
      end

      okx_24hr_tickers.map! do |ticker|
        from_symbol, to_symbol = ticker["instId"].split(/-/)
        open_price = ticker["sodUtc8"].to_f
        last_price = ticker["last"].to_f
        price_change = (ticker["last"].to_f - open_price) / open_price
        {
          "symbol" => from_symbol + to_symbol,
          "lastPrice" => last_price,
          "priceChangePercent" => (price_change * 100).round(3).to_s,
          "bottomPriceRatio" => get_bottom_price_ratio(from_symbol, last_price).to_s
        }
      end

      result = (binance_24hr_tickers + okx_24hr_tickers).group_by do |d|
        symbol = d["symbol"]
        from_symbol = symbol.split(/USDT/)[0]
        from_symbol = symbol.split(/BUSD/)[0] if from_symbol == symbol
        from_symbol = symbol.split(/USD/)[0] if from_symbol == symbol
        from_symbol
      end.map{|k,v| v[0]}

      result.delete_if { |r| r["symbol"].in?(['SRMUSDT', 'RAYUSDT']) }

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

    def get_bottom_price_ratio(symbol, price)
      url = ENV['COIN_ELITE_URL'] + "/api/user_positions/bottom_price_ratio?symbol=#{symbol}&price=#{price}"
      response = RestClient.get(url)
      data = JSON.parse(response)
      data["bottom_ratio"]
    end
  end
end