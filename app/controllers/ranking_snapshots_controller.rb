class RankingSnapshotsController < ApplicationController
  def index
    @page_index = 17
    infos = RankingSnapshot.all.group_by(&:event_date)
    @results = split_event_dates(infos)
  end

  def list
    @page_index = 17
    @daily_ranking = RankingSnapshot.where(event_date: params[:event_date]).get_daily_rankings
  end

  def get_24hr_tickers
    @page_index = 5
    @source = params[:source]
    @daily_ranking = JSON.parse($redis.get("get_24hr_tickers")) rescue []
    @top_3_symbol_funding_rates = JSON.parse($redis.get("top_3_symbol_funding_rates")) rescue []
    @top_select_ranking = JSON.parse($redis.get("get_top_24hr_tickers")) rescue @daily_ranking
    @bottom_select_ranking = JSON.parse($redis.get("get_bottom_24hr_tickers")) rescue @daily_ranking
    @bottom_select = $redis.get('bottom_select_ranking').to_i
    @top_select = $redis.get('top_select_ranking').to_i
    @duration = $redis.get('top_select_duration').presence || 12
    @daily_ranking = @daily_ranking.select{|d| d['source'] == @source} if @source.present?
    @symbols = @daily_ranking.map{|r| [r["symbol"], r["source"]] }
    @three_days_duration = $redis.get('three_days_duration') || 12
    @three_days_select = $redis.get('three_days_select').to_i
    @three_days_ranking = JSON.parse($redis.get("get_three_days_tickers_#{@three_days_duration}_#{@three_days_select}")) rescue []
    @weekly_duration = $redis.get('weekly_duration') || 12
    @weekly_select = $redis.get('weekly_select').to_i
    @weekly_ranking = JSON.parse($redis.get("get_one_week_tickers_#{@weekly_duration}_#{@weekly_select}")) rescue []
  end

  def refresh_tickers
    data_type = params[:data_type]
    duration = params[:three_days_duration] || params[:weekly_duration]
    rank = params[:three_days_select] || params[:weekly_select]
    RefreshRankingSnapshotsJob.perform_later(duration, rank, data_type)

    redirect_to get_24hr_tickers_ranking_snapshots_path(anchor: get_anchor(data_type)), notice: "正在更新，请稍等刷新查看最新排名..."
  end

  def ranking_graph
    @symbol = params[:symbol]
    @source = params[:source]
    to_date = Date.today
    from_date = to_date - 3.months
    @data = GetRankingChartDataService.execute(@symbol, @source)
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

  def get_anchor(data_type)
    case data_type
    when 'three_days'
      'three_days_select_table'
    when 'weekly'
      'weekly_select_table'
    else
      ''
    end
  end
end
