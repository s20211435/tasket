class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    # セッションで今日初回表示かどうかを管理
    today_key = "reminders_shown_#{Date.current.strftime('%Y%m%d')}"
    
    if !session[today_key] && current_user.today_reminders.exists?
      @active_reminders = current_user.today_reminders
      session[today_key] = true
    else
      @active_reminders = []
    end
  end

  def dismiss_reminder
    reminder = current_user.reminders.find(params[:id])
    reminder.destroy
    head :ok
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
