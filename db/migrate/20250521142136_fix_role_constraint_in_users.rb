class FixRoleConstraintInUsers < ActiveRecord::Migration[8.0]
  def up
    # 既存の制約を削除（エラーを無視）
    execute <<-SQL
      ALTER TABLE users DROP CONSTRAINT IF EXISTS role_check;
    SQL

    # 新しい制約を追加
    execute <<-SQL
      ALTER TABLE users ADD CONSTRAINT role_check CHECK (role IN ('superuser', 'user', 'admin'));
    SQL
  end

  def down
    # 新しい制約を削除
    execute <<-SQL
      ALTER TABLE users DROP CONSTRAINT IF EXISTS role_check;
    SQL

    # 元の制約を再追加
    execute <<-SQL
      ALTER TABLE users ADD CONSTRAINT role_check CHECK (role IN ('superuser', 'user'));
    SQL
  end
end
