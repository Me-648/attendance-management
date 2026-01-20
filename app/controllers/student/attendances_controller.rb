module Student
  class AttendancesController < BaseController
    def index
      @facade = Student::HomeFacade.new(current_user, params)
    end

    def show
      @attendance = current_user.attendances.find(params[:id])
      render layout: false
    end

    def create
      if apply_to_all?
        apply_attendance_to_all_periods
      else
        create_single_attendance
      end
    end

    def update
      if apply_to_all?
        apply_attendance_to_all_periods
      else
        update_single_attendance
      end
    end

    def form
      @period = Period.find(params[:period_id])
      @attendance = current_user.attendances.find_or_initialize_by(
        period_id: @period.id,
        date: Date.current
      )
      @attendance.status = params[:status] if params[:status].present?

      render layout: false
    end


    private

    def attendance_params
      params.require(:attendance).permit(:period_id, :status, :reason)
    end

    def apply_to_all?
      params[:apply_to_all] == "1" || params[:apply_to_all] == "true"
    end

    def create_single_attendance
      @attendance = current_user.attendances.build(attendance_params)
      @attendance.date = Date.current

      if @attendance.save
        render_success([ @attendance ])
      else
        render_failure(@attendance)
      end
    end

    def update_single_attendance
      @attendance = current_user.attendances.find(params[:id])

      if @attendance.update(attendance_params)
        render_success([ @attendance ])
      else
        render_failure(@attendance)
      end
    end

    def apply_attendance_to_all_periods
      # 今日の該当する全授業を取得
      periods = Period.where(weekday: Date.current.wday)
      safe_params = attendance_params.except(:period_id)
      saved_attendances = []

      error_occurred = false
      target_attendance = nil

      ActiveRecord::Base.transaction do
        periods.each do |period|
          att = Attendance.find_or_initialize_by(
            user: current_user,
            period: period,
            date: Date.current
          )
          att.assign_attributes(safe_params)

          if att.save
            saved_attendances << att
          else
            target_attendance = att
            error_occurred = true
            # エラー時のみロールバック
            raise ActiveRecord::Rollback
          end
        end
      end

      if error_occurred
        render_failure(target_attendance)
      else
        render_success(saved_attendances)
      end
    end

    def render_success(attendances)
      streams = attendances.map { |attendance|
        turbo_stream.replace(
          "attendance_period_#{attendance.period.id}",
          partial: "student/attendances/attendance_row",
          locals: { period: attendance.period, attendance: attendance }
        )
      }
      # モーダルはStimulus controller側で閉じるアニメーション後に削除されるため、ここでは削除しない
      render turbo_stream: streams
    end

    def render_failure(attendance)
      message = "エラーが発生しました: #{attendance.errors.full_messages.join(', ')}"
      render turbo_stream: [
        turbo_stream.update("modal", ""),
        turbo_stream.prepend("flash-messages", partial: "components/flash_message", locals: { type: "alert", message: message })
      ], status: :unprocessable_content
    end
  end
end
