class UserPositionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @page_index = 3
    sort = params[:sort].presence || "revenue"
    sort_type = params[:sort_type].presence || "desc"
    histories = UserPosition.available.where(user_id: current_user.id)
    histories = histories.where(from_symbol: params[:search].upcase) if params[:search].present?
    parts = histories.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @histories = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @histories = @histories.reverse if sort_type == "desc"
    @histories = Kaminari.paginate_array(@histories).page(params[:page]).per(15)
    @total_summary = UserPosition.available.total_summary(current_user.id)
    snapshots = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {user_id: current_user.id, event_date: Date.yesterday})
    @last_summary = snapshots.total_summary(current_user.id)
    @snapshots = snapshots.to_a
  end

  def import_csv
    if params[:file].blank?
      flash[:alert] = "请选择文件"
      redirect_to user_positions_path
    else
      import_status = ImportCsvService.new(params[:file], params[:source], current_user.id).call
      if import_status[:status].to_i == 1
        flash[:notice] = import_status[:message]
      else
        flash[:alert] = import_status[:message]
      end
      redirect_to user_positions_path
    end
  end

  def refresh
    redirect_to user_positions_path, notice: "正在更新，请稍等刷新查看最新价格以及其他信息..."
  end
end
