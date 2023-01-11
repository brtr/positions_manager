FactoryBot.define do
  factory :synced_transaction do
    origin_symbol { 'BTCUSDT' }
    fee_symbol { 'USDT' }
    trade_type { 'sell' }
    source { 'binance' }
    price { 1 }
    qty { 1 }
    amount { 1 }
    fee { 0.1 }
    revenue { 1 }
  end
end
