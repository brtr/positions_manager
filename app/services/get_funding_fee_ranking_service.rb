class GetFundingFeeRankingService
  class << self
    def execute
      redis_key = 'binance_future_funding_fee_list'
      rate_list = $redis.get(redis_key)
      if rate_list.nil?
        rate_list = BinanceFuturesService.new.get_funding_rate(nil, Date.today.strftime('%Q'))
        last_funding_time = rate_list.last['fundingTime']
        rate_list = rate_list.select{ |r| r['fundingTime'] == last_funding_time }.to_json

        $redis.set(redis_key, rate_list, ex: 2.hours)
      end

      JSON.parse(rate_list)
    end
  end
end