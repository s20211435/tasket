class RemoveRoleConstraintFromUsers < ActiveRecord::Migration[8.0]
  def up
    # 制約が存在する場合のみ削除
    if connection.check_constraint_exists?(:users, name: "role_check")
      remove_check_constraint(:users, name: "role_check")
    end
  end

  def down
    # 必要に応じてロールバック処理を追加
    # add_check_constraint(:users, "role IN ('admin', 'user')", name: "role_check")
  end
end
