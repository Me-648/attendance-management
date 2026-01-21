module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin!
    layout "admin"

    private
    # 管理者認証メソッド
    def authenticate_admin!
      unless current_user&.admin?
        redirect_to new_user_session_path, alert: "管理者権限が必要です。"
      end
    end
  end
end
