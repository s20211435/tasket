class CreateMenus < ActiveRecord::Migration[8.0]
  def change
    # テーブルが存在しない場合のみ作成
    unless table_exists?(:menus)
      create_table :menus do |t|
        t.string :name
        t.string :path
        t.string :icon
        t.integer :display_order
        t.boolean :active
        t.string :role

        t.timestamps
      end

      add_index :menus, :name, unique: true
      add_index :menus, :path, unique: true
      add_index :menus, :role
    end
  end
end
