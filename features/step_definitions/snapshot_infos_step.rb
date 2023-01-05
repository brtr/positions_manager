Given 'I have different snapshots' do
  info1 = create(:snapshot_info, event_date: Date.parse('2022-11-05'))
  create(:snapshot_position, snapshot_info: info1, from_symbol: "BTC", origin_symbol: "BTCUSDT", amount: 35, revenue: 24)
  create_list(:snapshot_position, 9, snapshot_info: info1, amount: 31, from_symbol: "EOS", origin_symbol: "EOSUSDT")

  info2 = create(:snapshot_info, event_date: Date.parse('2022-12-10'))
  create(:snapshot_position, snapshot_info: info2, from_symbol: "BTC", origin_symbol: "BTCUSDT", amount: 44)
  create_list(:snapshot_position, 9, snapshot_info: info2, amount: 25, from_symbol: "EOS", origin_symbol: "EOSUSDT")

  info3 = create(:snapshot_info)
  create(:snapshot_position, snapshot_info: info3, from_symbol: "BTC", origin_symbol: "BTCUSDT", amount: 27)
  create_list(:snapshot_position, 9, snapshot_info: info3, amount: 45, from_symbol: "EOS", origin_symbol: "EOSUSDT")
end

Given 'I have uploaded snapshot with user id' do
  user = User.first
  info = create(:snapshot_info, source_type: 'uploaded', user: user)
  create(:snapshot_position, snapshot_info: info, from_symbol: "BTC", origin_symbol: "BTCUSDT", amount: 27)
  create_list(:snapshot_position, 9, snapshot_info: info, amount: 45, from_symbol: "EOS", origin_symbol: "EOSUSDT")
end

Given 'I have synced snapshot with user id' do
  user = User.first
  info = create(:snapshot_info, source_type: 'synced', user: user)
  create(:snapshot_position, snapshot_info: info, from_symbol: "BTC", origin_symbol: "BTCUSDT", amount: 27)
  create_list(:snapshot_position, 9, snapshot_info: info, amount: 45, from_symbol: "EOS", origin_symbol: "EOSUSDT")
end