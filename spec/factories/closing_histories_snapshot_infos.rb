FactoryBot.define do
  factory :closing_histories_snapshot_info do
    event_date { Date.yesterday }
  end
end
