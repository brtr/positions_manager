FactoryBot.define do
  factory :transactions_snapshot_info do
    event_date { Date.yesterday }
  end
end
