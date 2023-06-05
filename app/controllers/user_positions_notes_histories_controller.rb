class UserPositionsNotesHistoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :get_user_position, except: [:edit, :update]

  def index
    @notes = UserPositionsNotesHistory.where(user_position_id: @record.id).order(created_at: :desc).page(params[:page]).per(15)
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

  def edit
    @note = current_user.user_positions_notes_histories.find_by(id: params[:id])
    @record = @note.user_position
  end

  def update
    @note = current_user.user_positions_notes_histories.find_by(id: params[:id])
    @note.update(note_params)

    redirect_to user_positions_notes_histories_path(user_position_id: @note.user_position_id), notice: "更新成功"
  end

  private
  def note_params
    params.require(:user_positions_notes_history).permit(:notes, :user_position_id)
  end

  def get_user_position
    @record = UserPosition.find_by id: params[:user_position_id]
  end
end
