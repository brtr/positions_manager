Given 'I have 10 user positions' do
  create_list(:user_position, 9)
  create(:user_position, from_symbol: "BTC", origin_symbol: "BTCUSDT", current_price: 0.5)
end

Given 'I have 10 user positions with user id' do
  user = User.first
  create_list(:user_position, 9, user: user)
  create(:user_position, from_symbol: "BTC", origin_symbol: "BTCUSDT", current_price: 0.5, user: user)
end