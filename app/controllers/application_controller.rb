class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  allow_browser versions: :modern   # 指定したブラウザーのバージョン以下のアクセスを拒否するための機能
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # サインアップ時（新規登録）に許可するパラメータ
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :student_id, :enrollment_year ])

    # アカウント情報更新時に許可するパラメータ（今回は特に不要だが慣習的に記述）
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :student_id, :enrollment_year ])
  end

  # Deviseの認証後に呼ばれるメソッド
  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      student_root_path
    end
  end
end
