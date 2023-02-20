class RankingSnapshotsController < ApplicationController
  def index
    @page_index = 5

    @daily_ranking = JSON.parse($redis.get("get_24hr_tickers")) rescue []
    @three_days_ranking = RankingSnapshot.where("event_date >= ?", Date.yesterday - 3.days).get_rankings
    @weekly_ranking = RankingSnapshot.where("event_date >= ?", Date.yesterday - 1.week).get_rankings
  end
end