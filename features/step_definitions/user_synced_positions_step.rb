Given 'I have 10 user synced positions with user id' do
  user = User.first
  create_list(:user_synced_position, 9, user: user)
  create(:user_synced_position, from_symbol: "BTC", origin_symbol: "BTCUSDT", current_price: 0.5, user: user)
end