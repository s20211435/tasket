class ModifyRoleInUsers < ActiveRecord::Migration[8.0]
  def change
    change_column :users, :role, :string, null: false, default: "user"
    add_check_constraint :users, "role IN ('superuser', 'user')", name: "role_check"
  end
end
