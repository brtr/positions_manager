Given 'I have 10 adding positions histories' do
  create(:user_position, from_symbol: "ETH", origin_symbol: "ETHUSDT", current_price: 0.5)
  create_list(:adding_positions_history, 5, origin_symbol: "ETHUSDT", qty: 5, source: 'binance', trade_type: 'buy', event_date: Date.yesterday)
  create_list(:adding_positions_history, 5, origin_symbol: "ETHUSDT", qty: -5, source: 'binance', trade_type: 'buy', event_date: Date.today)
end

When 'I visit the position detail page with 3rd party service' do
  allow(GetOpenOrdersService).to receive(:execute).and_return({})
  allow(GetPositionsChartDataService).to receive(:execute)
  allow(GetHoldingDurationsByRoiChartService).to receive(:execute_by_symbol).and_return({})
  allow(GetBinanceTradingDataService).to receive(:execute).and_return({})
  visit '/position_detail?origin_symbol=ETHUSDT&source=binance&trade_type=buy'
end