class FixRoleConstraintInUsers < ActiveRecord::Migration[8.0]
  def up
    # 既存の制約を削除（存在しない場合でもエラーを無視）
    begin
      remove_check_constraint :users, name: "role_check"
    rescue ActiveRecord::StatementInvalid
      # 制約が存在しない場合は無視
    end

    # 新しい制約を追加
    add_check_constraint :users, "role IN ('superuser', 'user', 'admin')", name: "role_check"
  end

  def down
    # 制約を削除
    remove_check_constraint :users, name: "role_check"

    # 元の制約を再追加
    add_check_constraint :users, "role IN ('superuser', 'user')", name: "role_check"
  end
end
