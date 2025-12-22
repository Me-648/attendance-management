module Student
  class AttendancesController < BaseController
    helper_method :attendance_status_badge, :attendance_action_buttons

    def index
      @today = Time.zone.today
      @periods = Period.where(weekday: @today.wday).order(:period_number)
      @attendances = current_user.attendances.where(date: @today).index_by(&:period_id)
    end

    def create
      @attendance = current_user.attendances.build(attendance_params)

      if @attendance.save
        redirect_to student_root_path, notice: "出席が記録されました。"
      else
        render :new
      end
    end

    def attendance_status_badge(attendance)
      return nil unless attendance

      text, klass = case attendance.status
      when "attended"
                      [ "出席", "bg-success" ]
      when "absent"
                      [ "欠席", "bg-danger" ]
      when "late"
                      [ "遅刻", "bg-warning" ]
      when "officially_absent"
                      [ "公欠", "bg-info" ]
      else
                      [ attendance.status, "bg-secondary" ]
      end

      view_context.tag.span text, class: "badge #{klass} fs-6"
    end

    def attendance_action_buttons(period)
      # 出席ボタン (受付時間内のみ)
      if period.reception_active?
        view_context.concat attendance_form(period, :attended, "出席する", "btn-primary")
        view_context.concat " "
      end

      # 欠席ボタン (常に表示)
      view_context.concat attendance_form(period, :absent, "欠席する", "btn-outline-danger")
    end

    private

    def attendance_form(period, status, label, btn_class)
      view_context.form_with(model: Attendance.new, url: student_attendances_path, method: :post, class: "d-inline") do |f|
        view_context.concat f.hidden_field :period_id, value: period.id
        view_context.concat f.hidden_field :status, value: status
        view_context.concat f.submit label, class: "btn #{btn_class} btn-sm"
      end
    end

    def attendance_params
      params.expect(attendance: [ :period_id, :status, :reason ]).merge(date: Time.zone.today)
    end

    def check_student_role
      unless current_user&.student?
        redirect_to root_path, alert: "学生のみアクセスできます。"
      end
    end
  end
end
