FactoryBot.define do
  factory :positions_summary_snapshot do
    total_cost { 1 }
    total_revenue { 1 }
    total_loss { 1 }
    total_profit { 1 }
    roi { 1 }
    revenue_change { 1 }
    event_date { Date.today }
  end
end
