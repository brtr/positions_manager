class PageController < ApplicationController
  def user_positions
    @page_index = 1
    sort = params[:sort].presence || "revenue"
    sort_type = params[:sort_type].presence || "desc"
    histories = UserPosition.available.where(user_id: nil)
    histories = histories.where(from_symbol: params[:search].upcase) if params[:search].present?
    parts = histories.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @histories = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @histories = @histories.reverse if sort_type == "desc"
    @histories = Kaminari.paginate_array(@histories).page(params[:page]).per(15)
    @total_summary = UserPosition.available.total_summary
    compare_date = params[:compare_date].presence || Date.yesterday
    snapshots = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {source_type: 'synced', user_id: nil, event_date: compare_date})
    @last_summary = snapshots.last_summary(data: @total_summary)
    @snapshots = snapshots.to_a
    flash[:alert] = "找不到相应的快照" if @snapshots.blank?
  end

  def refresh_user_positions
    GetPublicUserPositionsJob.perform_later

    redirect_to public_user_positions_path, notice: "正在更新，请稍等刷新查看最新仓位..."
  end

  def health_check
    render plain: "ok"
  end

  def get_24hr_ticker
    @page_index = 5
    @data = JSON.parse($redis.get("get_24hr_tickers")) rescue []
  end

  def refresh_24hr_ticker
    SyncFutures24hrTickerJob.perform_later

    redirect_to get_24hr_ticker_url, notice: "正在更新，请稍等刷新查看最新排名..."
  end
end
