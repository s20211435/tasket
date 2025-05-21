class FixRoleConstraintInUsers < ActiveRecord::Migration[8.0]
  def up
    # 既存の制約を削除（存在する場合のみ）
    if check_constraint_exists?(:users, name: "role_check")
      remove_check_constraint :users, name: "role_check"
    end

    # 新しい制約を追加
    add_check_constraint :users, "role IN ('superuser', 'user', 'admin')", name: "role_check"
  end

  def down
    # 新しい制約を削除
    remove_check_constraint :users, name: "role_check"

    # 元の制約を再追加
    add_check_constraint :users, "role IN ('superuser', 'user')", name: "role_check"
  end

  private

  def check_constraint_exists?(table_name, name:)
    ActiveRecord::Base.connection.check_constraints(table_name).any? { |c| c["name"] == name.to_s }
  end
end
