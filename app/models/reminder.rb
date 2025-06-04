class Reminder < ApplicationRecord
  belongs_to :event

  validates :title, presence: true
  validates :remind_at, presence: true
  validates :event_id, uniqueness: { scope: :remind_at }

  scope :upcoming, -> { where('remind_at > ?', Time.current) }
  scope :past, -> { where('remind_at <= ?', Time.current) }
  scope :by_date, -> { order(:remind_at) }
  scope :active_now, -> { where(remind_at: 1.day.ago..Time.current) }
  scope :today, -> { where(remind_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :for_kept_events, -> { joins(:event).where(events: { discarded_at: nil }) }

  def past?
    remind_at <= Time.current
  end

  def upcoming?
    remind_at > Time.current
  end

  def active?
    remind_at <= Time.current && remind_at >= Time.current.beginning_of_day
  end

  def event_deleted?
    event.discarded?
  end

  def should_remind?
    !event_deleted? && !past?
  end
end
