Rails.application.routes.draw do
  root "home#index" # ホーム画面

  # Deviseの新規登録機能を無効化
  devise_for :users

  get "home/index"

  # ユーザ管理画面のルートを追加
  resources :users, only: [:index, :new, :create, :edit, :update, :destroy] # ユーザ管理画面（スーパーユーザー用）
  resources :menus, only: [:index, :edit, :update] do
    patch :toggle_active, on: :member
  end

  # 商品管理画面のルートを追加
  resources :categories
  resources :products do
    collection do
      get :calculate
      get :index, defaults: { format: :html }
      get :export_empty_csv
      get :export_csv
      get :import_csv # CSV取り込み画面用のルート
      post :import_csv # CSV取り込み処理用のルート
      get :search
    end
  end

  resources :events

  # アプリケーションのルート設定
  get "up" => "rails/health#show", as: :rails_health_check
end
