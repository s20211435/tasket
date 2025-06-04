# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# スーパーユーザーを作成
admin_user = User.find_or_initialize_by(email: "admin@example.com")
if admin_user.new_record?
  admin_user.update!(
    name: "管理者",
    password: "password",
    password_confirmation: "password",
    role: "superuser" # スーパーユーザーの役割を示す
  )
end

# 一般ユーザーを作成
regular_user = User.find_or_initialize_by(email: "user@example.com")
if regular_user.new_record?
  regular_user.update!(
    name: "一般",
    password: "password",
    password_confirmation: "password",
    role: "user" # 一般ユーザーの役割を示す
  )
end

puts "ユーザーを確認しました"

# テスト用のイベントとリマインダーを作成
test_user = User.find_by(email: "user@example.com")
if test_user
  # 今日のテスト用イベントを作成
  test_event = Event.find_or_create_by(
    name: "テストイベント",
    user: test_user
  ) do |event|
    event.description = "リマインダーのテスト用イベントです"
    event.start_date = Date.current
    event.end_date = Date.current + 1.day
  end

  # 今日の現在時刻から1分後のリマインダーを作成
  future_time = Time.current + 1.minute
  test_reminder = Reminder.find_or_create_by(
    title: "テストリマインダー",
    remind_at: future_time,
    event: test_event
  )

  # 今日の現在時刻のリマインダーも作成
  current_reminder = Reminder.find_or_create_by(
    title: "現在のリマインダー",
    remind_at: Time.current,
    event: test_event
  )

  puts "テストイベントとリマインダーを作成しました"
  puts "イベント: #{test_event.name}"
  puts "リマインダー1: #{test_reminder.title} at #{test_reminder.remind_at}"
  puts "リマインダー2: #{current_reminder.title} at #{current_reminder.remind_at}"
else
  puts "テストユーザーが見つかりません"
end

# メニューマスタの初期データ
if Menu.count.zero?
  menus = [
    { name: 'ホーム', path: 'root_path', icon: 'fa-house', display_order: 1, active: true, role: nil },
    { name: '商品', path: 'products_path', icon: 'fa-cart-shopping', display_order: 2, active: true, role: nil },
    { name: 'カテゴリ', path: 'categories_path', icon: 'fa-list', display_order: 3, active: true, role: nil },
    { name: '商品金額計算', path: 'calculate_products_path', icon: 'fa-calculator', display_order: 4, active: true, role: nil },
    { name: 'CSV取り込み', path: 'import_csv_products_path', icon: 'fa-file-import', display_order: 5, active: true, role: nil },
    { name: 'メニュー管理', path: 'menus_path', icon: 'fa-bars', display_order: 6, active: true, role: nil }
  ]

  menus.each do |menu|
    Menu.find_or_create_by!(menu)
  end

  puts "#{Menu.count}件のメニューを作成しました"
else
  puts "メニューは既に存在します"
end
