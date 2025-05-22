class FixRoleConstraintInUsers < ActiveRecord::Migration[8.0]
  def up
    if ActiveRecord::Base.connection.adapter_name.downcase.include?("postgresql")
      # PostgreSQL用の制約を追加
      execute <<-SQL
        ALTER TABLE users DROP CONSTRAINT IF EXISTS role_check;
      SQL
      execute <<-SQL
        ALTER TABLE users ADD CONSTRAINT role_check CHECK ("role" IN ('superuser', 'user', 'admin'));
      SQL
    elsif ActiveRecord::Base.connection.adapter_name.downcase.include?("mysql")
      # MySQL用にENUM型を使用
      execute <<-SQL
        ALTER TABLE users MODIFY COLUMN role ENUM('superuser', 'user', 'admin') NOT NULL;
      SQL
    end
  end

  def down
    if ActiveRecord::Base.connection.adapter_name.downcase.include?("postgresql")
      # PostgreSQL用の制約を削除
      execute <<-SQL
        ALTER TABLE users DROP CONSTRAINT IF EXISTS role_check;
      SQL
    elsif ActiveRecord::Base.connection.adapter_name.downcase.include?("mysql")
      # MySQL用にVARCHAR型に戻す
      execute <<-SQL
        ALTER TABLE users MODIFY COLUMN role VARCHAR(255) NOT NULL;
      SQL
    end
  end
end
