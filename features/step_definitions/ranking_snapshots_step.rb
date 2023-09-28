Given 'I have 2 ranking snapshots' do
  allow(SyncFuturesTickerService).to receive(:get_price_ratio).and_return([])
  create(:ranking_snapshot, symbol: 'BTCUSDT', open_price: 100, last_price: 135, event_date: Date.parse('2023-01-05'))
  create(:ranking_snapshot, symbol: 'ETHUSDT', open_price: 2, last_price: 3.5, event_date: Date.parse('2023-02-08'))
  $redis.set('get_24hr_tickers', RankingSnapshot.get_rankings.to_json)
end