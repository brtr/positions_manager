class UserSpotBalancesController < ApplicationController
  before_action :authenticate_user!

  def index
    @page_index = 20
    sort = params[:sort].presence || "amount"
    sort_type = params[:sort_type].presence || "desc"
    @symbol = params[:search]
    histories = UserSpotBalance.where(user_id: current_user.id)
    histories = histories.where(origin_symbol: @symbol) if @symbol.present?
    parts = histories.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @histories = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @histories = @histories.reverse if sort_type == "desc"
    @histories = Kaminari.paginate_array(@histories).page(params[:page]).per(15)
  end
end
