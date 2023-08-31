class AddingPositionsHistoriesController < ApplicationController
  def index
    @page_index = 30
    @symbol = params[:origin_symbol]
    @source = params[:source]
    @trade_type = params[:trade_type]
    @event_date = params[:event_date]
    sort = params[:sort].presence || "event_date"
    sort_type = params[:sort_type].presence || "desc"
    histories = AddingPositionsHistory.available.closing_data
    @total_summary = histories.total_summary
    @symbols = histories.pluck(:origin_symbol).uniq
    histories = histories.where(trade_type: @trade_type) if @trade_type.present?
    histories = histories.where(source: @source) if @source.present?
    histories = histories.where(origin_symbol: @symbol) if @symbol.present?
    histories = histories.where(event_date: @event_date) if @event_date.present?
    parts = histories.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @histories = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @histories = @histories.reverse if sort_type == "desc"
    @histories = Kaminari.paginate_array(@histories).page(params[:page]).per(15)
    snapshots = ClosingHistoriesSnapshotRecord.joins(:closing_histories_snapshot_info).where(closing_histories_snapshot_info: {event_date: Date.yesterday})
    @last_summary = snapshots.last_summary(data: @total_summary)
    @snapshots = snapshots.to_a
  end
end
