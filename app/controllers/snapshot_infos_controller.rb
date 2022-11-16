class SnapshotInfosController < ApplicationController
  def index
    if params[:user_id].present?
      @page_index = 4
      infos = SnapshotInfo.where(user_id: params[:user_id]).pluck(:id, :event_date)
    else
      @page_index = 2
      infos = SnapshotInfo.where(user_id: nil).pluck(:id, :event_date)
    end
    @results = split_event_dates(infos)
  end

  def show
    @page_index = params[:user_id].present? ? 4 : 2
    @info = SnapshotInfo.find_by(id: params[:id])
    sort = params[:sort].presence || "revenue"
    sort_type = params[:sort_type].presence || "desc"
    records = @info.snapshot_positions
    records = records.where(from_symbol: params[:search]) if params[:search].present?
    @records = records.order("#{sort} #{sort_type}").page(params[:page]).per(20)
    @total_summary = records.total_summary(params[:user_id].presence)
  end

  def positions_graphs
    @page_index = 6
    infos = SnapshotInfo.includes(:snapshot_positions).where(user_id: nil, event_date: [Date.yesterday - 1.month..Date.yesterday]).order(event_date: :asc)
    @records = infos.map{|info| {info.event_date => info.snapshot_positions.total_summary.merge(date: info.event_date)}}.inject(:merge)
  end

  private

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
