class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :discarded_at

      t.timestamps
    end
    
    add_index :events, :discarded_at
    add_index :events, :start_date
  end
end
