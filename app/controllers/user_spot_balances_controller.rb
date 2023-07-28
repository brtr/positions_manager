class UserSpotBalancesController < ApplicationController
  before_action :authenticate_user!, only: [:index, :refresh]

  def index
    @page_index = 20
    sort = params[:sort].presence || "amount"
    sort_type = params[:sort_type].presence || "desc"
    @actual_balances = UserSpotBalance.actual_balance(current_user.id)
    @symbol = params[:search]
    histories = UserSpotBalance.where(user_id: current_user.id).available
    histories = histories.where(origin_symbol: @symbol) if @symbol.present?
    @total_summary = histories.summary
    snapshots = SpotBalanceSnapshotRecord.joins(:spot_balance_snapshot_info).where(spot_balance_snapshot_info: {user_id: current_user.id, event_date: Date.yesterday})
    @last_summary = snapshots.last_summary(data: @total_summary)
    @snapshots = snapshots.to_a
    parts = histories.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @histories = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @histories = @histories.reverse if sort_type == "desc"
    @histories = Kaminari.paginate_array(@histories).page(params[:page]).per(15)
  end

  def edit
    @record = UserSpotBalance.find_by_id params[:id]
  end

  def update
    @record = UserSpotBalance.find_by_id params[:id]
    @record.update(record_params)
    url = @record.user_id.present? ? user_spot_balances_path : public_spot_balances_path

    redirect_to url, notice: "更新成功"
  end

  def refresh
    SyncUsersSpotBalancesJob.perform_later(current_user.id)

    redirect_to user_spot_balances_path, notice: "正在更新，请稍等刷新查看最新结果..."
  end

  private
  def record_params
    params.require(:user_spot_balance).permit(:level)
  end
end
