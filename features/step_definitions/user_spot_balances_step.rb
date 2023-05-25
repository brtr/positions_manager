Given 'I have 10 user spot balances' do
  create_list(:user_spot_balance, 9)
  create(:user_spot_balance, from_symbol: "BTC", origin_symbol: "BTCUSDT")
end

Given 'I have 10 user spot balances with user id' do
  user = User.first
  create_list(:user_spot_balance, 9, user: user)
  create(:user_spot_balance, from_symbol: "BTC", origin_symbol: "BTCUSDT", user: user)
end