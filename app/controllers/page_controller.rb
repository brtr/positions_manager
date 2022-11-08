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
    snapshots = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {user_id: nil, event_date: Date.yesterday})
    @last_summary = snapshots.last_summary
    @snapshots = snapshots.to_a
  end

  def refresh_user_positions
    GetPublicUserPositionsJob.perform_later

    redirect_to public_user_positions_path, notice: "正在更新，请稍等刷新查看最新仓位..."
  end

  def health_check
    render plain: "ok"
  end
end
