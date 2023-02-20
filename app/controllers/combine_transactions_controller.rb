class CombineTransactionsController < ApplicationController
  def index
    @page_index = 9
    sort = params[:sort].presence || "revenue"
    sort_type = params[:sort_type].presence || "desc"
    txs = CombineTransaction.order("#{sort} #{sort_type}")
    txs = txs.where(source: params[:source]) if params[:source].present?
    txs = txs.where(from_symbol: params[:search].upcase) if params[:search].present?
    @txs = txs.page(params[:page]).per(20)
    @total_summary = txs.total_summary
  end
end
