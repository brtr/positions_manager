FactoryBot.define do
  factory :funding_fee_history do
    origin_symbol { 'BTCUSDT' }
    rate { 0.1 }
    amount { 1 }
  end
end
