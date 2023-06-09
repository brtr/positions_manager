class UserPositionsNotesHistoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :get_user_position, except: [:index, :edit, :update]
  before_action :get_note, only: [:show, :edit, :update, :destroy]

  def index
    @page_index = 24
    sort = params[:sort].presence || "created_at"
    sort_type = params[:sort_type].presence || "desc"
    @symbol = params[:origin_symbol]
    @source = params[:source]
    @trade_type = params[:trade_type]
    histories = UserPositionsNotesHistory.includes(:user, :user_position)
    histories = histories.select{|h| h.origin_symbol == @symbol} if @symbol.present?
    histories = histories.select{|h| h.source == @source} if @source.present?
    histories = histories.select{|h| h.trade_type == @trade_type} if @trade_type.present?
    parts = histories.partition {|h| h.send("#{sort}").nil? || h.send("#{sort}") == 'N/A'}
    @histories = parts.last.sort_by{|h| h.send("#{sort}")} + parts.first
    @histories = @histories.reverse if sort_type == "desc"
    @histories = Kaminari.paginate_array(@histories).page(params[:page]).per(15)
  end

  def new
    @note = current_user.user_positions_notes_histories.where(user_position_id: @record.id).build
  end

  def create
    @note = current_user.user_positions_notes_histories.where(user_position_id: @record.id).build
    @note.update(note_params)
    url = if @record.user_id.present?
            user_positions_path
          elsif params[:position_detail].present?
            position_detail_path(origin_symbol: @record.origin_symbol, source: @record.source, trade_type: @record.trade_type)
          else
            public_user_positions_path
          end

    redirect_to url, notice: "添加备注成功"
  end

  def show
  end

  def edit
    @record = @note.user_position
  end

  def update
    @note.attachments.delete_all if note_params[:images].present?
    @note.update(note_params)

    redirect_to user_positions_notes_histories_path(user_position_id: @note.user_position_id), notice: "更新成功"
  end

  def destroy
    user_position_id = @note.user_position_id
    @note.destroy

    redirect_to user_positions_notes_histories_path(user_position_id: user_position_id), notice: "删除成功"
  end

  private
  def note_params
    params.require(:user_positions_notes_history).permit(:notes, :user_position_id, images: [])
  end

  def get_user_position
    @record = UserPosition.find_by id: params[:user_position_id]
  end

  def get_note
    @note = current_user.user_positions_notes_histories.find_by(id: params[:id])
  end
end
