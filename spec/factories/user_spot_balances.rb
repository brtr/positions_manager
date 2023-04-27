FactoryBot.define do
  factory :user_spot_balance do
    origin_symbol { "EOSUSDT" }
    from_symbol { "EOS" }
    to_symbol { "USDT" }
    source { "binance" }
    price { 1 }
    qty { 1 }
    amount { 1 }
  end
end
