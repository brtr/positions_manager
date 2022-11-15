FactoryBot.define do
  factory :snapshot_position do
    snapshot_info
    origin_symbol { "SFPUSDT" }
    from_symbol { "SFP" }
    fee_symbol { "USDT" }
    trade_type { "buy" }
    source { "binance" }
    price { 0.5529 }
    qty { 119 }
    amount { 65.8 }
    estimate_price { 0.7507 }
    revenue { -23.5333 }
    event_date { snapshot_info.event_date }
  end
end
