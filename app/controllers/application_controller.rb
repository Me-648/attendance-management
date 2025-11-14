class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  # Deviseの認証後に呼ばれるメソッド
  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path # 事前に routes.rb で admin_root へのルーティング定義が必要です
    else
      student_root_path # 事前に routes.rb で student_root へのルーティング定義が必要です
    end
  end
end
