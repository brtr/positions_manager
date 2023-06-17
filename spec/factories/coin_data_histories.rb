FactoryBot.define do
  factory :coin_data_history do
    symbol { 'btc' }
    source { 'binance' }
    event_date { Date.today }
  end
end
