class DropEvents < ActiveRecord::Migration[8.0]
  def up
    # 外部キー制約チェックを無効化
    execute "SET FOREIGN_KEY_CHECKS = 0"

    # eventsテーブルが存在する場合は削除
    drop_table :events if table_exists?(:events)

    # 外部キー制約チェックを再有効化
    execute "SET FOREIGN_KEY_CHECKS = 1"
  end

  def down
    # ロールバック時の処理（必要に応じて）
    raise ActiveRecord::IrreversibleMigration
  end
end
