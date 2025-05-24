class RemoveRoleCheckConstraintFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_check_constraint :users, name: "role_check"
  end
end
