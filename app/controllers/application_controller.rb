class ApplicationController < ActionController::Base
  # ほとんどのコントローラーで認証を要求
  before_action :authenticate_user!

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  
  def configure_permitted_parameters
    # サインアップ時（新規登録）に許可するパラメータ
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :student_id, :enrollment_year])
    
    # アカウント情報更新時に許可するパラメータ（今回は特に不要だが慣習的に記述）
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :student_id, :enrollment_year])
  end

  # Deviseの認証後に呼ばれるメソッド
  def after_sign_in_path_for(resource)
    if resource.is_admin?
      # 管理者ログインの成功パス
      admin_root_path
    else
      # 学生ログインの成功パス
      student_root_path
    end
  end
end
