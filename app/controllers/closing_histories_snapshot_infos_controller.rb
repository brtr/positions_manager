class ClosingHistoriesSnapshotInfosController < ApplicationController
  def index
    @page_index = 31
    infos = ClosingHistoriesSnapshotInfo.pluck(:id, :event_date)
    @results = split_event_dates(infos)
  end

  def show
    @page_index = 31
    @info = ClosingHistoriesSnapshotInfo.find_by(id: params[:id])
    sort = params[:sort].presence || "event_date"
    sort_type = params[:sort_type].presence || "desc"
    histories = @info.closing_histories_snapshot_records
    @symbol = params[:origin_symbol]
    @source = params[:source]
    @trade_type = params[:trade_type]
    @symbols = histories.pluck(:origin_symbol).uniq
    histories = histories.where(trade_type: @trade_type) if @trade_type.present?
    histories = histories.where(source: @source) if @source.present?
    histories = histories.where(origin_symbol: @symbol) if @symbol.present?
    @histories = histories.order("#{sort} #{sort_type}").page(params[:page]).per(20)
    @snapshots = ClosingHistoriesSnapshotRecord.joins(:closing_histories_snapshot_info).where(closing_histories_snapshot_info: {event_date: @info.event_date - 1.day}).to_a
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
