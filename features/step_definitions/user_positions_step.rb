Given 'I have 10 user positions' do
  create_list(:user_position, 9)
  create(:user_position, from_symbol: "BTC", origin_symbol: "BTCUSDT", current_price: 0.5)
end

Given 'I have a yesterday snapshot' do
  info = create(:snapshot_info)
  create(:snapshot_position, from_symbol: "BTC", origin_symbol: "BTCUSDT", estimate_price: 0.15)
  create_list(:snapshot_position, 9, snapshot_info: info, estimate_price: 0.5)
end

Given 'I have a last week snapshot' do
  info = create(:snapshot_info, event_date: Date.parse('2022-12-01'))
  create(:snapshot_position, from_symbol: "BTC", origin_symbol: "BTCUSDT", estimate_price: 0.35)
  create_list(:snapshot_position, 9, snapshot_info: info, estimate_price: 0.5)
end