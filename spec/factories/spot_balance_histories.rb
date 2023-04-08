FactoryBot.define do
  factory :spot_balance_history do
    asset { 'BTC' }
    free { 1 }
    locked { 1 }
    event_date { Date.today }
  end
end
