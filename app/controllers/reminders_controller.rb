class RemindersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_reminder, only: [:show, :edit, :update, :destroy]

  # GET /events/:event_id/reminders
  def index
    @reminders = @event.reminders.by_date
  end

  # GET /events/:event_id/reminders/:id
  def show
  end

  # GET /events/:event_id/reminders/new
  def new
    @reminder = @event.reminders.build
  end

  # POST /events/:event_id/reminders
  def create
    @reminder = @event.reminders.build(reminder_params)

    if @reminder.save
      redirect_to event_reminder_path(@event, @reminder), notice: 'リマインダーが正常に作成されました。'
    else
      render :new
    end
  end

  # GET /events/:event_id/reminders/:id/edit
  def edit
  end

  # PATCH/PUT /events/:event_id/reminders/:id
  def update
    if @reminder.update(reminder_params)
      redirect_to event_reminder_path(@event, @reminder), notice: 'リマインダーが正常に更新されました。'
    else
      render :edit
    end
  end

  # DELETE /events/:event_id/reminders/:id
  def destroy
    @reminder.destroy
    redirect_to event_reminders_path(@event), notice: 'リマインダーが正常に削除されました。'
  end

  private

  def set_event
    @event = current_user.events.find(params[:event_id])
  end

  def set_reminder
    @reminder = @event.reminders.find(params[:id])
  end

  def reminder_params
    params.require(:reminder).permit(:title, :remind_at)
  end
end
