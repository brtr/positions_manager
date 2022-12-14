class SnapshotInfosController < ApplicationController
  def index
    if params[:user_id].present?
      if params[:is_synced].present?
        @page_index = 8
        infos = SnapshotInfo.synced.where(user_id: params[:user_id]).pluck(:id, :event_date)
      else
        @page_index = 4
        infos = SnapshotInfo.uploaded.where(user_id: params[:user_id]).pluck(:id, :event_date)
      end
    else
      @page_index = 2
      infos = SnapshotInfo.synced.where(user_id: nil).pluck(:id, :event_date)
    end
    @results = split_event_dates(infos)
  end

  def show
    user_id = params[:user_id].presence
    @info = SnapshotInfo.find_by(id: params[:id])
    @page_index = user_id.nil? ? 2 : (@info.synced? ? 8 : 4)
    sort = params[:sort].presence || "revenue"
    sort_type = params[:sort_type].presence || "desc"
    records = @info.snapshot_positions
    records = records.where(from_symbol: params[:search]) if params[:search].present?
    @records = records.order("#{sort} #{sort_type}").page(params[:page]).per(20)
    @total_summary = records.total_summary(user_id, @info.synced?)
    snapshots = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {source_type: @info.source_type, user_id: user_id, event_date: @info.event_date - 1.day})
    @last_summary = snapshots.last_summary(user_id: user_id, data: @total_summary)
  end

  def positions_graphs
    @page_index = 6
    infos = SnapshotInfo.includes(:snapshot_positions).where(user_id: nil, event_date: [period_date..Date.yesterday]).order(event_date: :asc)
    @roi_summary = SnapshotInfo.get_roi_summary
    @records = infos.map do |info|
      total_summary = info.snapshot_positions.total_summary
      last_summary = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {user_id: nil, event_date: info.event_date - 1.day}).last_summary(data: total_summary)
      {info.event_date => total_summary.merge(revenue_change: last_summary[:total_revenue], date: info.event_date)}
    end.inject(:merge)
  end

  def export_roi
    infos = SnapshotInfo.includes(:snapshot_positions).where(user_id: nil, event_date: [Date.today.last_quarter.to_date..Date.yesterday]).order(event_date: :desc)

    file = CSV.generate(force_quotes: true) do |csv|
      csv << ['??????', '?????????', '?????????', '????????????']
      infos.each do |info|
        total_summary = info.snapshot_positions.total_summary
        total_cost = total_summary[:total_cost]
        total_revenue = total_summary[:total_revenue]
        roi = ((total_revenue / total_cost) * 100).round(3).to_s + "%"
        csv << [info.event_date, total_cost.round(3), total_revenue.round(3), roi]
      end
    end

    respond_to do |format|
      format.csv { send_data file, filename: "records.csv" }
    end
  end

  private

  def period_date
    case params[:period]
    when "quarter" then Date.today.last_quarter.to_date
    else Date.today.last_month.to_date
    end
  end

  def split_event_dates(infos)
    date_records = []

    years = infos.map {|k| k[1].year}.uniq.sort
    months = infos.map {|k| k[1].month}.uniq.sort

    years.each do |y|
      monthes_array = []
      months.each do |m|
        set_month = m.to_i >= 10 ? m : "0#{m}"
        records = infos.select {|k| k[1].to_s.include?("#{y}-#{set_month}")}
        days = records.map {|k| {id: k[0], day: k[1].day}}.sort_by { |k| k[:day] }
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
