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

  # スーパーユーザー判定メソッド
  def superuser?
    self.role == "superuser" # 例: roleカラムが"superuser"の場合
  end

  private

  def set_default_role
    self.role ||= "user"
  end
end
