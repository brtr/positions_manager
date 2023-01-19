Given 'I have 2 ranking snapshots' do
  create(:ranking_snapshot, symbol: 'BTCUSDT', open_price: 100, last_price: 135)
  create(:ranking_snapshot, symbol: 'ETHUSDT', open_price: 2, last_price: 3.5)
  $redis.set('get_24hr_tickers', RankingSnapshot.get_rankings.to_json)
end