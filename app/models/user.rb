class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: true

  # スーパーユーザー判定メソッド
  def superuser?
    self.role == "superuser" # 例: roleカラムが"superuser"の場合
  end
end
