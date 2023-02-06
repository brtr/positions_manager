class UserSyncedPositionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @page_index = 7
    sort = params[:sort].presence || "revenue"
    sort_type = params[:sort_type].presence || "desc"
    histories = UserSyncedPosition.available.where(user_id: current_user.id)
    histories = histories.where(from_symbol: params[:search].upcase) if params[:search].present?
    parts = histories.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @histories = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @histories = @histories.reverse if sort_type == "desc"
    @histories = Kaminari.paginate_array(@histories).page(params[:page]).per(15)
    @total_summary = UserSyncedPosition.available.total_summary(current_user.id)
    compare_date = params[:compare_date].presence || Date.yesterday
    snapshots = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {source_type: 'synced', user_id: current_user.id, event_date: compare_date})
    @last_summary = snapshots.last_summary(user_id: current_user.id, data: @total_summary)
    @snapshots = snapshots.to_a
  end

  def add_key
    if params[:api_key].blank? || params[:secret_key].blank?
      flash[:alert] = 'API KEY / SECRET KEY 不能为空'
    else
      if current_user.update(api_key: params[:api_key], secret_key: Base64.encode64(params[:secret_key]))
        is_valid = BinanceFuturesService.new(user_id: current_user.id).get_account rescue nil
        if is_valid
          flash[:notice] = '币安API KEY绑定成功'
        else
          current_user.update(api_key: nil, secret_key: nil)
          flash[:alert] = '币安API KEY绑定失败，请检查后重试'
        end
      else
        flash[:alert] = current_user.errors.full_messages
      end
    end

    redirect_to user_synced_positions_path
  end

  def refresh
    if current_user.api_key.present? && current_user.secret_key.present?
      GetPrivateUserPositionsJob.perform_later(current_user.id)
      flash[:notice] = "正在更新，请稍等刷新查看最新仓位..."
    else
      flash[:alert] = "请绑定API KEY后再尝试刷新仓位"
    end

    redirect_to user_synced_positions_path
  end
end
