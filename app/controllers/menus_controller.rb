class MenusController < ApplicationController
  before_action :authenticate_user!
  before_action :set_menu, only: [:edit, :update, :toggle_active]

  def index
    # 初回アクセス時にユーザーのメニュー設定を初期化
    current_user.initialize_menu_settings

    # ユーザーのメニュー設定を取得
    @user_menus = current_user.user_menus.includes(:menu).joins(:menu).order('menus.display_order')
  end

  def edit
    # メニューの編集画面で、ユーザー固有の設定を取得
    @user_menu = current_user.user_menus.find_or_initialize_by(menu: @menu)
  end

  def update
    @user_menu = current_user.user_menus.find_or_initialize_by(menu: @menu)

    if @user_menu.update(user_menu_params)
      redirect_to menus_path, notice: 'メニュー設定が更新されました'
    else
      render :edit
    end
  end

  def toggle_active
    @user_menu = current_user.user_menus.find_or_initialize_by(menu: @menu)
    @user_menu.active = !@user_menu.active
    @user_menu.save
    redirect_to menus_path
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def user_menu_params
    params.require(:user_menu).permit(:active)
  end
end
