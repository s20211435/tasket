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
User.find_or_create_by!(email: "superuser@example.com") do |user|
  user.name = "Super User" # 必須の`name`を設定
  user.password = "password"
  user.password_confirmation = "password"
  user.role = "superuser" # スーパーユーザーの役割を示す
end

# 一般ユーザーを作成
User.find_or_create_by!(email: "user@example.com") do |user|
  user.name = "Regular User" # 必須の`name`を設定
  user.password = "password"
  user.password_confirmation = "password"
  user.role = "user" # 一般ユーザーの役割を示す
end
