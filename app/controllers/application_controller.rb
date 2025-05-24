class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # ログイン後のリダイレクト先を設定
  def after_sign_in_path_for(resource)
    if resource.superuser? # スーパーユーザーの場合
      users_path # ユーザ管理画面（例: /users）
    else
      root_path # 一般ユーザーの場合はホーム画面
    end
  end

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
