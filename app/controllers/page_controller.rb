class PageController < ApplicationController
  def user_positions
    @page_index = 1
    @flag = params[:switch_filter].nil? || params[:switch_filter].to_i == 1
    @max_amount = $redis.get('max_amount_filter_flag').to_f
    sort = params[:sort].presence || "revenue"
    sort_type = params[:sort_type].presence || "desc"
    histories = UserPosition.available.where(user_id: nil)
    histories = histories.where(from_symbol: params[:search].upcase) if params[:search].present?
    histories = histories.select{|h| h.amount < @max_amount} if @flag && @max_amount > 0
    parts = histories.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @histories = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @histories = @histories.reverse if sort_type == "desc"
    @histories = Kaminari.paginate_array(@histories).page(params[:page]).per(15)
    @total_summary = UserPosition.available.total_summary
    compare_date = params[:compare_date].presence || Date.yesterday
    snapshots = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {source_type: 'synced', user_id: nil, event_date: compare_date})
    @last_summary = snapshots.last_summary(data: @total_summary)
    @snapshots = snapshots.to_a
    flash[:alert] = "找不到相应的快照" if params[:compare_date].present? && @snapshots.blank?
  end

  def export_user_positions
    @total_summary = UserPosition.available.total_summary
    histories = UserPosition.available.where(user_id: nil)
    histories = histories.where(from_symbol: params[:search].upcase) if params[:search].present?
    compare_date = params[:compare_date].presence || Date.yesterday
    snapshots = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {source_type: 'synced', user_id: nil, event_date: compare_date})

    file = "合约仓位列表.csv"
    CSV.open(file, "w") do |writer|
      writer << positions_table_headers.map{|h| h[:name]}
      histories.each do |h|
        snapshot = snapshots.select{|s| s.origin_symbol == h.origin_symbol && s.trade_type == h.trade_type && s.source == h.source}.first
        writer << [ display_symbol(h, snapshot), I18n.t("views.contract_trading.#{h.trade_type}"), "#{h.price.round(4)} #{h.fee_symbol}",
                    "#{h.current_price.to_f.round(4)} #{h.fee_symbol}", h.qty.round(4), position_amount_display(h, snapshot, html_safe: false),
                    "#{(h.cost_ratio(@total_summary[:total_cost]) * 100).round(3)}%", position_revenue_display(h, snapshot, html_safe: false),
                    "#{h.margin_revenue} #{h.fee_symbol}", "#{(h.roi * 100).round(3)}%", "#{(h.revenue_ratio(@total_summary[:total_revenue]) * 100).round(3)}%",
                    "#{(h.margin_ratio.to_f * 100).round(3)}%", h.source]
      end
    end

    respond_to do |format|
      format.csv { send_file file }
    end
  end

  def refresh_user_positions
    GetPublicUserPositionsJob.perform_later

    redirect_to public_user_positions_path, notice: "正在更新，请稍等刷新查看最新仓位..."
  end

  def health_check
    render plain: "ok"
  end

  def refresh_24hr_ticker
    SyncFutures24hrTickerJob.perform_later

    redirect_to ranking_snapshots_path, notice: "正在更新，请稍等刷新查看最新排名..."
  end

  def recently_adding_positions
    @page_index = 12
    @to_date = Date.parse(params[:to_date]) rescue Date.yesterday
    @from_date = params[:from_date].presence || @to_date - 1.week

    if params[:from_date].present? || params[:to_date].present?
      GetAddingPositionsService.execute(@from_date, @to_date)
      @original_data = JSON.parse($redis.get('filters_adding_positions')) rescue []
    else
      @original_data = JSON.parse($redis.get('recently_adding_positions')) rescue []
    end

    @data = Kaminari.paginate_array(@original_data).page(params[:page]).per(15)
  end

  def refresh_recently_adding_positions
    GetRecentlyAddingPositionsJob.perform_later

    redirect_to recently_adding_positions_path, notice: "正在更新，请稍等刷新查看最新结果..."
  end

  def account_balance
    @page_index = 14
    @binance_data = BinanceFuturesService.new.get_positions
    @okx_data = OkxFuturesService.get_account
  end

  def price_chart
    @page_index = 15
    GetPriceChartDataService.execute(params[:period])
    @chart_data = JSON.parse($redis.get('monthly_chart_data')) rescue []
  end

  def set_public_positions_filter
    $redis.set('max_amount_filter_flag', params[:max_amount])

    redirect_to root_path
  end
end
