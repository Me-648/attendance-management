module Admin
  class AttendancesController < BaseController
    # 指定された授業回の出席データを表示
    def by_period
      form_params = {
        year: params[:year],
        month: params[:month],
        day: params[:day],
        period_number: (params[:period] || 1),
        enrollment_year: params[:enrollment_year],
        current_user: current_user
      }

      @attendances = AttendanceSearchForm.new(form_params)

      if @attendances.search
        render partial: "by_period"
      else
        flash[:alert] = @attendances.errors.full_messages.join("\n")
        redirect_to admin_root_path
      end
    end

    # 欠席理由を表示
    def reason
      @attendance = Attendance.find(params[:id])
      @student = @attendance.user
      @period = @attendance.period
    end

    # 生徒の累計出席情報を表示
    def total
      @student = User.find(params[:id])
      @stats = Attendance.stats_for_user(@student.id)
    end
  end
end
