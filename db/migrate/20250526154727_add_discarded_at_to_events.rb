class AddDiscardedAtToEvents < ActiveRecord::Migration[8.0]
  def change
    # カラムが存在しない場合のみ追加
    unless column_exists?(:events, :discarded_at)
      add_column :events, :discarded_at, :datetime
    end
  end
end
