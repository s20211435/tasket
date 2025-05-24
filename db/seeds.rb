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

# メニューマスタの修正データ
menus = [
  { name: 'ホーム', path: '/', icon: 'fa-house', display_order: 1, active: true, role: nil },
  { name: '商品', path: '/products', icon: 'fa-cart-shopping', display_order: 2, active: true, role: nil },
  { name: 'カテゴリ', path: '/categories', icon: 'fa-list', display_order: 3, active: true, role: nil },
  { name: '商品金額計算', path: '/products/calculate', icon: 'fa-calculator', display_order: 4, active: true, role: nil },
  { name: 'CSV取り込み', path: '/products/import_csv', icon: 'fa-file-import', display_order: 5, active: true, role: nil },
  { name: 'メニュー管理', path: '/menus', icon: 'fa-bars', display_order: 6, active: true, role: nil }
]

# 既存のメニューを更新
menus.each do |menu_data|
  menu = Menu.find_by(name: menu_data[:name])
  if menu
    menu.update!(path: menu_data[:path])
    puts "メニュー「#{menu.name}」のパスを更新しました: #{menu.path}"
  end
end
