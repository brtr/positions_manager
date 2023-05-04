class SpotBalanceSnapshotInfosController < ApplicationController
  before_action :authenticate_user!

  def index
    @page_index = 21
    infos = SpotBalanceSnapshotInfo.where(user_id: current_user.id).pluck(:id, :event_date)
    @results = split_event_dates(infos)
  end

  def show
    @info = SpotBalanceSnapshotInfo.find_by(id: params[:id])
    @page_index = 21
    sort = params[:sort].presence || "amount"
    sort_type = params[:sort_type].presence || "desc"
    records = @info.spot_balance_snapshot_records
    @symbol = params[:search]
    records = records.where(origin_symbol: @symbol) if @symbol.present?
    @records = records.order("#{sort} #{sort_type}").page(params[:page]).per(20)
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
