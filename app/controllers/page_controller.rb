class PageController < ApplicationController
  def user_positions
    @page_index = 1
    @flag = params[:switch_filter].nil? || params[:switch_filter].to_i == 1
    @max_amount = $redis.get('max_amount_filter_flag').to_f
    @daily_market_data = JSON.parse($redis.get('daily_market_data')) rescue {}
    sort = params[:sort].presence || "revenue"
    sort_type = params[:sort_type].presence || "desc"
    @symbol = params[:search]
    histories = UserPosition.available.where(user_id: nil)
    histories = histories.where(origin_symbol: @symbol) if @symbol.present?
    histories = histories.where(level: params[:level]) if params[:level].present?
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
    @average_holding_durations = CoinHoldingDuration.average_durations
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
                    "#{(h.cost_ratio(@total_summary[:total_cost]) * 100).round(4)}%", position_revenue_display(h, snapshot, html_safe: false),
                    "#{h.margin_revenue} #{h.fee_symbol}", "#{(h.roi * 100).round(4)}%", "#{(h.revenue_ratio(@total_summary[:total_revenue]) * 100).round(4)}%",
                    "#{(h.margin_ratio.to_f * 100).round(4)}%", h.source]
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

    redirect_to get_24hr_tickers_ranking_snapshots_path, notice: "正在更新，请稍等刷新查看最新排名..."
  end

  def recently_adding_positions
    @page_index = 12
    @to_date = Date.parse(params[:to_date]) rescue Date.today
    @from_date = Date.parse(params[:from_date]) + 1.day rescue Date.yesterday
    @symbol = params[:origin_symbol]
    sort = params[:sort].presence || "event_date"
    sort_type = params[:sort_type].presence || "desc"
    data = AddingPositionsHistory.where('current_price is not null and (amount > ? or amount < ?) and event_date between ? and ?', 1, -1, @from_date, @to_date)
    data = data.where(origin_symbol: @symbol) if @symbol.present?
    parts = data.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    data = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    data = data.reverse if sort_type == "desc"
    @data = Kaminari.paginate_array(data).page(params[:page]).per(15)
  end

  def refresh_recently_adding_positions
    GetAddingPositionsHistoriesJob.perform_later

    redirect_to recently_adding_positions_path, notice: "正在更新，请稍等刷新查看最新结果..."
  end

  def account_balance
    @page_index = 14
    @binance_data = BinanceFuturesService.new.get_positions
    @okx_data = OkxFuturesService.new.get_account
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

  def position_detail
    @symbol = params[:origin_symbol].upcase rescue nil
    @source = params[:source]
    @trade_type = params[:trade_type]
    @data = AddingPositionsHistory.where('current_price is not null and (amount > ? or amount < ?) and origin_symbol = ? and source = ? and trade_type = ?', 1, -1, @symbol, @source, @trade_type)
                                  .order(event_date: :desc)
    if @data.any?
      @target_position = @data.first.target_position
      @open_orders = if params[:source] == 'binance'
                      BinanceFuturesService.new.get_pending_orders(@symbol)
                    else
                      OkxFuturesService.new.get_pending_orders(@symbol)
                    end
      GetPositionsChartDataService.execute(@symbol, @source, @trade_type)
      @chart_data = JSON.parse($redis.get("#{@symbol}_monthly_chart_data")) rescue []
      @average_durations = @data.average_holding_duration
    end
    @binance_trading_data = GetBinanceTradingDataService.execute(@symbol)
  end

  def adding_positions_calendar
    @page_index = 16
    start_date = params.fetch(:start_date, Date.today).to_date
    @data = AddingPositionsHistory.where('current_price is not null and (amount > ? or amount < ?) and event_date between ? and ?', 1, -1, start_date.beginning_of_month.beginning_of_week, start_date.end_of_month.end_of_week).order(event_date: :asc)
  end

  def spot_balances
    @page_index = 23
    sort = params[:sort].presence || "amount"
    sort_type = params[:sort_type].presence || "desc"
    @symbol = params[:search]
    histories = UserSpotBalance.where(user_id: nil)
    @symbols = histories.pluck(:origin_symbol)
    histories = histories.where(origin_symbol: @symbol) if @symbol.present?
    histories = histories.where(level: params[:level]) if params[:level].present?
    parts = histories.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @histories = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @histories = @histories.reverse if sort_type == "desc"
    @histories = Kaminari.paginate_array(@histories).page(params[:page]).per(15)
  end

  def refresh_public_spot_balances
    SyncPublicSpotBalancesJob.perform_later

    redirect_to public_spot_balances_path, notice: "正在更新，请稍等刷新查看最新结果..."
  end

  def funding_fee_chart
    @page_index = 25
    @symbol = params[:symbol]
    @source = params[:source]
    @to_date = Date.parse(params[:to_date]) rescue Date.today
    @from_date = Date.parse(params[:from_date]) + 1.day rescue @to_date - 3.months

    histories = FundingFeeHistory.includes(:snapshot_position).where('funding_fee_histories.user_id is null and funding_fee_histories.event_date >= ? and funding_fee_histories.event_date <= ?', @from_date, @to_date).order(event_date: :asc)
    histories = histories.where(origin_symbol: @symbol) if @symbol.present?
    histories = histories.where(source: @source) if @source.present?
    @data_summary = histories.data_summary
    @data = {}
    total_amount = FundingFeeHistory.where('user_id is null and event_date < ?', @from_date).sum(&:amount)
    histories.group_by(&:event_date).each do |date, value|
      amount = value.sum(&:amount)
      total_amount += amount
      @data[date] = { amount: amount, revenue: value.sum(&:revenue), total_amount: total_amount, date: date }
    end
  end

  def funding_fee_ranking
    @page_index = 27
    @data = GetFundingFeeRankingService.execute.sort_by{|x| x['fundingRate'].to_f}
  end

  def refresh_funding_fee_list
    $redis.del('binance_future_funding_fee_list')

    redirect_to funding_fee_ranking_path, notice: '资金费率刷新成功'
  end

  def liquidations_ranking
    @page_index = 28
    @data = GetLiquidationsRankingService.execute.sort_by{|x| x['rate'].to_f}
  end

  def refresh_liquidations_list
    $redis.del('top_liquidatioins_list')

    redirect_to liquidations_ranking_path, notice: '爆仓数据刷新成功'
  end
end
