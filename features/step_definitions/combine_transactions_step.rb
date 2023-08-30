Given 'I have 2 combine transactions' do
  create(:combine_transaction, to_symbol: "USDT", amount: 8)
  create(:combine_transaction, from_symbol: "BTC", to_symbol: "USDT", revenue: 19, roi: 1.2)
end