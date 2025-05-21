class FixRoleConstraintInUsers < ActiveRecord::Migration[8.0]
  def up
    # カラムを`ENUM`型に変更
    execute <<-SQL
      ALTER TABLE users MODIFY COLUMN role ENUM('superuser', 'user', 'admin') NOT NULL;
    SQL
  end

  def down
    # 元のカラム定義に戻す（例: `VARCHAR`型）
    execute <<-SQL
      ALTER TABLE users MODIFY COLUMN role VARCHAR(255) NOT NULL;
    SQL
  end
end
