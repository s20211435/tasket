class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  def index
    @q = Event.ransack(params[:q])
    @events = @q.result.includes(:user).page(params[:page]).per(10).where(discarded_at: nil, user_id: current_user.id)
  end

  # GET /events/:id
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # POST /events
  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render :new
    end
  end

  # GET /events/:id/edit
  def edit
  end

  # PATCH/PUT /events/:id
  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /events/:id
  def destroy
    @event.destroy
    redirect_to events_url, notice: 'Event was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def event_params
    params.require(:event).permit(:name, :date, :location, :description)
  end
end
