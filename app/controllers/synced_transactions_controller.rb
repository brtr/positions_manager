class SyncedTransactionsController < ApplicationController
  def index
    @page_index = 11
    @flag = params[:switch_filter].nil? || params[:switch_filter].to_i == 1
    sort = params[:sort].presence || "event_time"
    sort_type = params[:sort_type].presence || "desc"
    @symbol = params[:search]
    txs = SyncedTransaction.where(user_id: nil)
    @total_symbols = txs.pluck(:origin_symbol).uniq
    txs = txs.where(origin_symbol: @symbol) if @symbol.present?
    txs = txs.available if @flag
    parts = txs.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @txs = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @txs = @txs.reverse if sort_type == "desc"
    @txs = Kaminari.paginate_array(@txs).page(params[:page]).per(15)
    @total_summary = txs.total_summary
  end

  def users
    @page_index = 18
    @flag = params[:switch_filter].nil? || params[:switch_filter].to_i == 1
    sort = params[:sort].presence || "event_time"
    sort_type = params[:sort_type].presence || "desc"
    @symbol = params[:search]
    txs = SyncedTransaction.where(user_id: current_user.id)
    @total_symbols = txs.pluck(:origin_symbol).uniq
    txs = txs.where(origin_symbol: @symbol) if @symbol.present?
    txs = txs.available if @flag
    parts = txs.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @txs = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @txs = @txs.reverse if sort_type == "desc"
    @txs = Kaminari.paginate_array(@txs).page(params[:page]).per(15)
    @total_summary = txs.total_summary(user_id: current_user.id)
  end

  def import_csv
    if params[:file].blank?
      flash[:alert] = "请选择文件"
      redirect_to users_synced_transactions_path
    else
      import_status = ImportTradeCsvService.new(params[:file], params[:source], current_user.id).call
      if import_status[:status].to_i == 1
        flash[:notice] = import_status[:message]
      else
        flash[:alert] = import_status[:message]
      end
      redirect_to users_synced_transactions_path
    end
  end
end
