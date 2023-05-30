class UserSpotBalancesController < ApplicationController
  before_action :authenticate_user!, only: :index

  def index
    @page_index = 20
    sort = params[:sort].presence || "amount"
    sort_type = params[:sort_type].presence || "desc"
    @symbol = params[:search]
    histories = UserSpotBalance.where(user_id: current_user.id).available
    histories = histories.where(origin_symbol: @symbol) if @symbol.present?
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

  private
  def record_params
    params.require(:user_spot_balance).permit(:level)
  end
end
