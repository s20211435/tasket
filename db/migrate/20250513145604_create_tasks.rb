class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.string :status
      t.string :priority
      t.datetime :due_date
      t.references :user, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :tasks }
      t.timestamps
    end
    add_index :tasks, [ :user_id, :due_date ], unique: true
    add_index :tasks, [ :user_id, :status ], unique: true
    add_index :tasks, [ :user_id, :priority ], unique: true
  end
end
