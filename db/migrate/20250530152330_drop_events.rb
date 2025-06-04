class DropEvents < ActiveRecord::Migration[8.0]
  def up
    # PostgreSQLでは外部キー制約を個別に削除
    if foreign_key_exists?(:reminders, :events)
      remove_foreign_key :reminders, :events
    end
    
    # テーブルを削除
    drop_table :events if table_exists?(:events)
  end

  def down
    # eventsテーブルを再作成
    create_table :events do |t|
      t.string "name", null: false
      t.text "description"
      t.datetime "start_date"
      t.datetime "end_date"
      t.datetime "discarded_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "user_id", null: false
    end

    # インデックスを追加
    add_index :events, :user_id, name: "index_events_on_user_id"

    # 外部キー制約を再追加
    add_foreign_key "events", "users" if table_exists?(:users)
    add_foreign_key "reminders", "events" if table_exists?(:reminders)
  end
end
