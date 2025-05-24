class User < ApplicationRecord
  include Discard::Model
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_validation :set_default_role, on: :create

  ROLES = { superuser: "管理者", user: "一般" }.freeze

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :role, inclusion: { in: ["superuser", "user"] }

  has_many :categories, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :user_menus, dependent: :destroy
  has_many :menus, through: :user_menus

  # スーパーユーザー判定メソッド
  def superuser?
    self.role == "superuser" # 例: roleカラムが"superuser"の場合
  end

  # ユーザーの表示メニューを取得するメソッド
  def visible_menus
    # UserMenuが存在するメニューはその設定を使用
    # 存在しないメニューはデフォルトのactive設定を使用
    Menu.ordered.left_outer_joins(:user_menus)
        .where('(user_menus.user_id = ? AND user_menus.active = true) OR (user_menus.user_id IS NULL AND menus.active = true)', id)
  end

  # 初回アクセス時などにユーザーのメニュー設定を初期化
  def initialize_menu_settings
    Menu.all.each do |menu|
      user_menus.find_or_create_by(menu: menu) do |user_menu|
        user_menu.active = menu.active
      end
    end
  end

  private

  def set_default_role
    self.role ||= "user"
  end
end
