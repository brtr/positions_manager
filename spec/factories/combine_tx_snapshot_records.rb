FactoryBot.define do
  factory :combine_tx_snapshot_record do
    combine_tx_snapshot_info
    original_symbol { "EOSUSDT" }
    from_symbol { "EOS" }
    fee_symbol { "USDT" }
    trade_type { "buy" }
    source { "binance" }
    price { 1 }
    qty { 2 }
    amount { 2 }
    current_price { 1.5 }
    revenue { 1 }
    roi { 0.5 }
  end
end
