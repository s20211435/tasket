class CreateReminders < ActiveRecord::Migration[8.0]
  def change
    create_table :reminders do |t|
      t.string :title
      t.datetime :remind_at
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
    add_index :reminders, [ :event_id, :remind_at ], unique: true
    add_index :reminders, :remind_at
  end
end
