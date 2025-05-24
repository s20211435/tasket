class AddUserToCategories < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:categories, :user_id)
      add_reference :categories, :user, null: false, foreign_key: true
    end
  end
end
