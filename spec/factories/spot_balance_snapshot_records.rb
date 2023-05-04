FactoryBot.define do
  factory :spot_balance_snapshot_record do
    spot_balance_snapshot_info
    origin_symbol { "EOSUSDT" }
    from_symbol { "EOS" }
    to_symbol { "USDT" }
    source { "binance" }
    price { 1 }
    qty { 1 }
    amount { 1 }
  end
end
