class UsersController < ApplicationController
  before_action :authenticate_user! # ログインしていない場合はリダイレクト
  before_action :ensure_superuser   # スーパーユーザーのみアクセス可能

  def index
    @users = User.all # ユーザー一覧を取得
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html { render :new }
      format.turbo_stream
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to users_path, notice: "ユーザーが作成されました。" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("user_form", partial: "form", locals: { user: @user }) }
        format.html { render :new }
      end
    end
  end

  def edit
    @user = User.find(params[:id]) # 編集するユーザーを取得
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to users_path, notice: "ユーザー情報が更新されました。" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("user_form", partial: "form", locals: { user: @user }) }
        format.html { render :edit }
      end
    end
  end

  def destroy
    @user = User.find(params[:id]) # 削除するユーザーを取得
    if @user.destroy
      redirect_to users_path, notice: "ユーザーが削除されました。" # 削除成功時のリダイレクト
    else
      redirect_to users_path, alert: "ユーザーの削除に失敗しました。" # 削除失敗時のリダイレクト
    end
  end

  private

  def ensure_superuser
    redirect_to root_path, alert: "アクセス権限がありません。" unless current_user.superuser?
  end

  def user_params
    params.require(:user).permit(:name, :email, :role, :password, :password_confirmation)
  end
end
