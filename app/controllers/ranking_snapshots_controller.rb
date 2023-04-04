class RankingSnapshotsController < ApplicationController
  def index
    @page_index = 17
    infos = RankingSnapshot.all.group_by(&:event_date)
    @results = split_event_dates(infos)
  end

  def list
    @page_index = 17
    @daily_ranking = RankingSnapshot.where(event_date: params[:event_date]).get_rankings
  end

  def get_24hr_tickers
    @page_index = 5
    if params[:select].to_i > 0
      SyncFutures24hrTickerJob.perform_later(params[:select].to_i)
      flash[:notice] = "正在更新，请稍等刷新查看最新排名..."
    end
    @symbols = RankingSnapshot.pluck(:symbol).uniq
    @daily_ranking = JSON.parse($redis.get("get_24hr_tickers")) rescue []
    @three_days_ranking = RankingSnapshot.where("event_date >= ?", Date.yesterday - 3.days).get_rankings
    @weekly_ranking = RankingSnapshot.where("event_date >= ?", Date.yesterday - 1.week).get_rankings
  end

  def ranking_graph
    @symbol = params[:symbol]
    to_date = Date.today
    from_date = to_date - 3.months
    @data = GetRankingChartDataService.execute(@symbol, params[:source])
  end

  private

  def split_event_dates(infos)
    date_records = []

    years = infos.map {|k| k[0].year}.uniq.sort
    months = infos.map {|k| k[0].month}.uniq.sort

    years.each do |y|
      monthes_array = []
      months.each do |m|
        set_month = m.to_i >= 10 ? m : "0#{m}"
        date = Date.strptime("#{y}-#{set_month}","%Y-%m")
        records = RankingSnapshot.where(event_date: date.beginning_of_month..date.end_of_month)
        days = records.map {|k| {id: k.id, day: k.event_date.day}}.uniq{|k| k[:day]}.sort_by { |k| k[:day] }
        if days.present?
          monthes_array.push({
            month: m,
            dates: days
          })
        end
      end
      date_records.push({
        year: y,
        monthes: monthes_array
       })
    end

    date_records
  end
end
