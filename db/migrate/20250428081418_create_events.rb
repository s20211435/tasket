class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title, null: false # タイトル
      t.text :description # 説明
      t.date :start_time, null: false # 開始日時
      t.date :end_time # 終了日時
      t.references :user, null: false, foreign_key: true # ユーザーID
      t.timestamps
    end

    add_index :events, [ :user_id, :start_time ], unique: true
    add_index :events, [ :user_id, :end_time ], unique: true
  end
end
