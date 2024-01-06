class OriginTransactionsController < ApplicationController
  before_action :authenticate_user!, only: :users

  def index
    @page_index = 8
    sort = params[:sort].presence || "event_time"
    sort_type = params[:sort_type].presence || "desc"
    txs = OriginTransaction.available.year_to_date.where(user_id: nil).order("#{sort} #{sort_type}")
    @total_txs = txs
    txs = filter_txs(txs)
    @event_date = Date.parse(params[:event_date]) rescue nil
    txs = txs.where(event_time: @event_date.all_day) if @event_date.present?
    @txs = txs.page(params[:page]).per(20)
    @total_summary = txs.total_summary
  end

  def users
    @page_index = 19
    sort = params[:sort].presence || "event_time"
    sort_type = params[:sort_type].presence || "desc"
    txs = OriginTransaction.available.year_to_date.where(user_id: current_user.id).order("#{sort} #{sort_type}")
    @total_txs = txs
    txs = filter_txs(txs)
    @txs = txs.page(params[:page]).per(20)
    @total_summary = txs.total_summary(current_user.id)
  end

  def new_platforms
    @page_index = 38
    sort = params[:sort].presence || "event_time"
    sort_type = params[:sort_type].presence || "desc"
    txs = OriginTransaction.where(source: ['gate', 'bitget']).order("#{sort} #{sort_type}")
    @total_txs = txs
    txs = filter_txs(txs)
    @event_date = Date.parse(params[:event_date]) rescue nil
    txs = txs.where(event_time: @event_date.all_day) if @event_date.present?
    @txs = txs.page(params[:page]).per(20)
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

    url = @tx.user_id.present? ? users_origin_transactions_path : origin_transactions_path

    redirect_to url
  end

  def refresh
    if params[:user_id].present?
      GetUsersSpotTransactionsJob.perform_later(params[:user_id])
      url = users_origin_transactions_path
    else
      GetSpotTransactionsJob.perform_later
      url = origin_transactions_path
    end

    redirect_to url, notice: "正在更新，请稍等刷新查看最新价格以及其他信息..."
  end

  def add_key
    if params[:okx_api_key].blank? || params[:okx_secret_key].blank? || params[:okx_passphrase].blank?
      flash[:alert] = 'API KEY / SECRET KEY / PASSPHRASE 不能为空'
    else
      if current_user.update(okx_api_key: params[:okx_api_key], okx_secret_key: Base64.encode64(params[:okx_secret_key]), okx_passphrase: Base64.encode64(params[:okx_passphrase]))
        is_valid = OkxSpotsService.new(user_id: current_user.id).get_orders rescue nil
        if is_valid
          flash[:notice] = 'OKX API KEY绑定成功'
        else
          current_user.update(okx_api_key: nil, okx_secret_key: nil)
          flash[:alert] = 'OKX API KEY绑定失败，请检查后重试'
        end
      else
        flash[:alert] = current_user.errors.full_messages
      end
    end

    redirect_to users_origin_transactions_path
  end

  def revenue_chart
    @page_index = 34
    infos = TransactionsSnapshotInfo.where(event_date: [period_date..Date.yesterday]).order(event_date: :asc)
    @records = infos.map do |info|
      {info.event_date => info.total_revenue}
    end.inject(:merge)
  end

  private
  def tx_params
    params.require(:origin_transaction).permit(:campaign)
  end

  def period_date
    case params[:period]
    when "quarter" then Date.today.last_quarter.to_date
    else Date.today.last_month.to_date
    end
  end

  def filter_txs(txs)
    @symbol = params[:search]
    @campaign = params[:campaign]
    @source = params[:source]
    @trade_type = params[:trade_type]

    txs = txs.where(campaign: @campaign) if @campaign.present?
    txs = txs.where(source: @source) if @source.present?
    txs = txs.where(original_symbol: @symbol) if @symbol.present?
    txs = txs.where(trade_type: @trade_type) if @trade_type.present?
    txs
  end
end
