module Student
  class BaseController < ApplicationController
    before_action :authenticate_student!
    around_action :travel_to_virtual_time, if: -> { Rails.env.development? }

    private

    # 開発環境用：時間操作ロジック
    def travel_to_virtual_time
      if session[:virtual_time].present?
        require "active_support/testing/time_helpers"
        # コントローラインスタンスにHelperをincludeして使えるようにする
        unless self.class < ActiveSupport::Testing::TimeHelpers
          self.class.include ActiveSupport::Testing::TimeHelpers
        end

        # 指定時刻にtravelする
        target_time = Time.zone.parse(session[:virtual_time])
        travel_to(target_time) do
          logger.debug "  [Development] Time Traveling to: #{Time.current}"
          yield
        end
      else
        yield
      end
    end

    # 生徒認証メソッド
    def authenticate_student!
      unless current_user&.student?
        redirect_to new_user_session_path, alert: "生徒のみアクセス可能です。"
      end
    end
  end
end
