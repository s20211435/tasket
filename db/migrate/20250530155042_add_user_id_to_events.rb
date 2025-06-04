class AddUserIdToEvents < ActiveRecord::Migration[8.0]
  def change
    # カラムが存在しない場合のみ追加
    unless column_exists?(:events, :user_id)
      add_reference :events, :user, null: false, foreign_key: true
    end
  end
end
