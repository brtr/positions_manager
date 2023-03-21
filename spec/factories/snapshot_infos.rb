FactoryBot.define do
  factory :snapshot_info do
    event_date { Date.yesterday }
    source_type { 'synced' }
    increase_count { 1 }
    decrease_count { 1 }
    btc_change { 1 }
    btc_change_ratio { 1 }
    total_cost { 1 }
    total_revenue { 1 }
    total_roi { 1 }
    profit_count { 1 }
    profit_amount { 1 }
    loss_count { 1 }
    loss_amount { 1 }
    max_profit { 1 }
    max_loss { 1 }
    max_revenue { 1 }
    min_revenue { 1 }
    max_roi { 1 }
    max_roi_date { 1 }
    min_roi { 1 }
    min_roi_date { 1 }
  end
end
