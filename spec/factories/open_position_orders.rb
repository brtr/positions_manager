FactoryBot.define do
  factory :open_position_order do
    symbol { 'BTCUSDT' }
    price { 1 }
    orig_qty { 1 }
  end
end
