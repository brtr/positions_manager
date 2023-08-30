class GetOpenOrdersService
  class << self
    def execute(symbol, source)
      if source == 'binance'
        BinanceFuturesService.new.get_pending_orders(symbol)
      else
        OkxFuturesService.new.get_pending_orders(symbol)
      end
    end
  end
end