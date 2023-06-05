class UserPositionsController < ApplicationController
  before_action :authenticate_user!, except: [:edit, :update]

  def index
    @page_index = 3
    sort = params[:sort].presence || "revenue"
    sort_type = params[:sort_type].presence || "desc"
    @symbol = params[:search]
    histories = UserPosition.available.where(user_id: current_user.id)
    histories = histories.where(origin_symbol: @symbol) if @symbol.present?
    parts = histories.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @histories = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @histories = @histories.reverse if sort_type == "desc"
    @histories = Kaminari.paginate_array(@histories).page(params[:page]).per(15)
    @total_summary = UserPosition.available.total_summary(current_user.id)
    compare_date = params[:compare_date].presence || Date.yesterday
    snapshots = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {source_type: 'uploaded', user_id: current_user.id, event_date: compare_date})
    @last_summary = snapshots.last_summary(user_id: current_user.id, data: @total_summary)
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
    GetPrivateUserPositionsInfoJob.perform_later(current_user.id)

    redirect_to user_positions_path, notice: "正在更新，请稍等刷新查看最新价格以及其他信息..."
  end

  def edit
    @record = UserPosition.find_by_id params[:id]
  end

  def update
    @record = UserPosition.find_by_id params[:id]
    @record.update(record_params)
    @record.user_positions_notes_histories.create(user_id: current_user.id, notes: record_params[:notes])
    url = if @record.user_id.present?
            user_positions_path
          elsif params[:only_notes].present?
            position_detail_path(origin_symbol: @record.origin_symbol, source: @record.source, trade_type: @record.trade_type)
          else
            public_user_positions_path
          end

    redirect_to url, notice: "更新成功"
  end

  private
  def record_params
    params.require(:user_position).permit(:level, :notes)
  end
end
