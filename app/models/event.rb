class Event < ApplicationRecord
  include Discard::Model
  
  belongs_to :user
  has_many :reminders, dependent: :destroy
  accepts_nested_attributes_for :reminders, allow_destroy: true

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  # イベントが削除（discard）された際のコールバック
  after_discard :handle_reminders_on_discard

  # Ransack用の検索可能属性を定義
  def self.ransackable_attributes(auth_object = nil)
    %w[name description start_date end_date created_at updated_at]
  end

  # Ransack用の検索可能な関連付けを定義（必要に応じて）
  def self.ransackable_associations(auth_object = nil)
    %w[user reminders]
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date

    if end_date < start_date
      errors.add(:end_date, 'は開始日以降の日付を選択してください')
    end
  end

  def handle_reminders_on_discard
    # イベントが削除された際に、関連するリマインダーも物理削除する
    reminders.destroy_all
  end
end
