class ApplicationController < ActionController::Base
  # ほとんどのコントローラーで認証を要求
  # ログインしていない場合はログインページにリダイレクトされる
  before_action :authenticate_user!

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

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
