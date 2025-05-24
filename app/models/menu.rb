class Menu < ApplicationRecord
  validates :name, presence: true
  validates :path, presence: true
  validates :icon, presence: true
  validates :display_order, presence: true, numericality: { only_integer: true }

  has_many :user_menus, dependent: :destroy
  has_many :users, through: :user_menus

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(display_order: :asc) }

  # 現在のユーザーに表示すべきメニューを取得するメソッドを修正
  def self.visible_for(user)
    return active.ordered unless user

    # ユーザーが存在する場合は、そのユーザーの設定に基づいて表示
    user.visible_menus
  end
end
