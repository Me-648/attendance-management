module Student
  class BaseController < ApplicationController
    before_action :authenticate_student!


    private

    def authenticate_student!
      unless current_user&.student?
        redirect_to new_user_session_path, alert: "学生のみアクセスできます。"
      end
    end
  end
end
