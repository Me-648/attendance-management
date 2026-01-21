module Admin
  class UsersController < BaseController
    def index
      @enrollment_year = params[:enrollment_year]
      return redirect_to admin_root_path, alert: "入学年度を指定してください。" if @enrollment_year.blank?

      @students = User.student.order(:student_id).where(enrollment_year: @enrollment_year)
    end
  end
end
