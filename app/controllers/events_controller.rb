class EventsController < ApplicationController
  before_action :authenticate_user! # Deviseの認証を追加
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  def index
    @q = Event.ransack(params[:q])
    # current_userがnilでないことを確認
    if current_user
      @events = @q.result.includes(:user).page(params[:page]).per(10).kept.where(user_id: current_user.id)
    else
      redirect_to new_user_session_path, alert: 'ログインが必要です。'
    end
  end

  # GET /events/:id
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
    @event.reminders.build # 初期のリマインダーフォームを1つ作成
  end

  # POST /events
  def create
    @event = Event.new(event_params)
    @event.user = current_user # ユーザーを設定
    if @event.save
      redirect_to @event, notice: '作成に成功しました'
    else
      render :new
    end
  end

  # GET /events/:id/edit
  def edit
    @event.reminders.build if @event.reminders.empty? # リマインダーがない場合は1つ作成
  end

  # PATCH/PUT /events/:id
  def update
    if @event.update(event_params)
      redirect_to @event, notice: '編集に成功しました'
    else
      render :edit
    end
  end

  # DELETE /events/:id
  def destroy
    if @event.respond_to?(:discard)
      @event.discard
    else
      @event.destroy
    end
    redirect_to events_url, notice: 'イベントを削除しました'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = current_user.events.kept.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def event_params
    params.require(:event).permit(:name, :description, :start_date, :end_date, :location,
                                  reminders_attributes: [:id, :title, :remind_at, :_destroy])
  end
end
