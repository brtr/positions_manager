FactoryBot.define do
  factory :ranking_snapshot do
    symbol do
      loop do
        s = "#{Faker::CryptoCoin.coin_hash[:acronym]}USDT"
        break s unless RankingSnapshot.exists?(symbol: s)
      end
    end
    source { 'binance' }
    open_price { 1 }
    last_price { 1 }
    price_change_rate { 1 }
    bottom_price_ratio { 1 }
    event_date { Date.today }
  end
end
