class CreateUserMenus < ActiveRecord::Migration[8.0]
  def change
    # テーブルが存在しない場合のみ作成
    unless table_exists?(:user_menus)
      create_table :user_menus do |t|
        t.references :user, null: false, foreign_key: true
        t.references :menu, null: false, foreign_key: true
        t.boolean :active, default: true

        t.timestamps
      end
      add_index :user_menus, [:user_id, :menu_id], unique: true
    end
  end
end
