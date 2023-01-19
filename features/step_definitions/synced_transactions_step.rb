Given 'I have 10 synced transactions' do
  create_list(:synced_transaction, 9, origin_symbol: "ETHUSDT")
  create(:synced_transaction, origin_symbol: "BTCUSDT", amount: 10, revenue: 10)
end