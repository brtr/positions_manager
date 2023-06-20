FactoryBot.define do
  factory :coin_holding_duration do
    symbol { 'BTCUSDT' }
    source { 'binance' }
    trade_type { 'buy' }
  end
end
