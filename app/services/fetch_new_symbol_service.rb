require 'openssl'
require 'rest-client'

class FetchNewSymbolService
  BASE_URL = ENV['BINANCE_ANNOUNCEMENT_URL']

  class << self
    def execute
      redis_key = 'binance_announcement_fetch_time'
      last_fetch_time = $redis.get(redis_key).to_i
      page = Nokogiri::HTML(URI.open(BASE_URL), nil, 'UTF-8')
      data = JSON.parse(page.css("script").children[15])
      catalog = data['appState']['loader']['dataByRouteId']['d969']['catalogs'].select{|c| c['catalogName'] == '数字货币及交易对上新'}.first rescue nil
      return if catalog.nil?

      $redis.set(redis_key, Time.current.to_i * 1000)
      catalog['articles'].select{|a| a['releaseDate'] >= last_fetch_time && a['title'].match(/将上线.*永续合约/)}.map{|a| a['title']}
    end
  end
end