module Student
  module Development
    class TimeTravelController < BaseController
      def update
        if params[:virtual_time].present?
          session[:virtual_time] = params[:virtual_time]
        else
          session.delete(:virtual_time)
        end
        # 戻り先がない場合は学生トップへ
        redirect_back_or_to("/student")
      end
    end
  end
end
