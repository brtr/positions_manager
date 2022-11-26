FactoryBot.define do
  factory :snapshot_info do
    event_date { Date.yesterday }
    source_type { 'synced' }
  end
end
