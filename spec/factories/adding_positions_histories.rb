FactoryBot.define do
  factory :adding_positions_history do
    origin_symbol { "EOSUSDT" }
    from_symbol { "EOS" }
    fee_symbol { "USDT" }
    trade_type { "buy" }
    source { "binance" }
    price { 1.7965 }
    qty { 17.1 }
    current_price { 0.919 }
  end
end
