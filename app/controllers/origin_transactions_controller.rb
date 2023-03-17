class OriginTransactionsController < ApplicationController
  def index
    @page_index = 8
    sort = params[:sort].presence || "event_time"
    sort_type = params[:sort_type].presence || "desc"
    @symbol = params[:search]
    txs = OriginTransaction.where(trade_type: 'buy').order("#{sort} #{sort_type}")
    txs = txs.where(campaign: params[:campaign]) if params[:campaign].present?
    txs = txs.where(source: params[:source]) if params[:source].present?
    txs = txs.where(original_symbol: @symbol) if @symbol.present?
    @txs = txs.page(params[:page]).per(20)
    @total_summary = txs.total_summary
  end

  def edit
    @tx = OriginTransaction.find params[:id]
  end

  def update
    @tx = OriginTransaction.find_by_id params[:id]
    if tx_params[:campaign].present?
      @tx.update(tx_params)
      flash[:notice] = "更新成功"
    else
      flash[:alert] = "campaign不能为空，请重新输入"
    end

    redirect_to origin_transactions_path
  end

  def refresh
    GetSpotTransactionsJob.perform_later

    redirect_to origin_transactions_path, notice: "正在更新，请稍等刷新查看最新价格以及其他信息..."
  end

  private
  def tx_params
    params.require(:origin_transaction).permit(:campaign)
  end
end
