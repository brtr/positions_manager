class WalletHistoriesController < ApplicationController
  def index
    @page_index = 32
    @symbol = params[:symbol]
    @trade_type = params[:trade_type]
    @apply_date = Date.parse(params[:apply_date]) rescue nil
    sort = params[:sort].presence || "apply_time"
    sort_type = params[:sort_type].presence || "desc"
    histories = WalletHistory.all
    @symbols = histories.pluck(:symbol).uniq
    histories = histories.where(trade_type: @trade_type) if @trade_type.present?
    histories = histories.where(symbol: @symbol) if @symbol.present?
    histories = histories.where(apply_time: @apply_date.all_day) if @apply_date.present?
    parts = histories.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @histories = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @histories = @histories.reverse if sort_type == "desc"
    @histories = Kaminari.paginate_array(@histories).page(params[:page]).per(15)
  end
end
