Given 'I have 10 origin transactions' do
  create_list(:origin_transaction, 9, to_symbol: "USDT", campaign: 'test1')
  create(:origin_transaction, from_symbol: "BTC", to_symbol: "USDT", revenue: 10, roi: 1, campaign: 'test2')
end