class GetLiquidationsRankingService
  class << self
    def execute
      redis_key = 'top_liquidatioins_list'
      rate_list = $redis.get(redis_key)
      if rate_list.nil?
        data = CoinglassService.get_top_liquidations['data']
        data.map! do |d|
          long_val = d['longVolUsd']
          short_val = d['shortVolUsd']
          rate = short_val / long_val
          d.merge!(rate: rate)
        end

        rate_list = data.to_json

        $redis.set(redis_key, rate_list, ex: 2.hours)
      end

      JSON.parse(rate_list)
    end
  end
end