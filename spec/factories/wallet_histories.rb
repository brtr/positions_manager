FactoryBot.define do
  factory :wallet_history do
    trade_type { 'withdraw' }
    symbol { 'USDT' }
    amount { 100 }
    fee { 1 }
  end
end
