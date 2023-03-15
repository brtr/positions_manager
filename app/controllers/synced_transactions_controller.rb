class SyncedTransactionsController < ApplicationController
  def index
    @page_index = 11
    @flag = params[:switch_filter].nil? || params[:switch_filter].to_i == 1
    sort = params[:sort].presence || "event_time"
    sort_type = params[:sort_type].presence || "desc"
    txs = SyncedTransaction.all
    txs = txs.where(origin_symbol: params[:search].upcase) if params[:search].present?
    txs = txs.available if @flag
    parts = txs.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @txs = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @txs = @txs.reverse if sort_type == "desc"
    @txs = Kaminari.paginate_array(@txs).page(params[:page]).per(15)
    @total_summary = txs.total_summary
  end
end
