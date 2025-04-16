Rails.application.routes.draw do
  root "home#index" # ホーム画面

  # Deviseの新規登録機能を無効化
  devise_for :users

  get "home/index"

  # ユーザ管理画面のルートを追加
  resources :users, only: [:index, :new, :create, :edit, :update, :destroy] # ユーザ管理画面（スーパーユーザー用）

  # 商品管理画面のルートを追加
  resources :products
  # アプリケーションのルート設定
  get "up" => "rails/health#show", as: :rails_health_check
end
