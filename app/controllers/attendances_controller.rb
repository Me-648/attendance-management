class AttendancesController < ApplicationController
  before_action :check_student_role

    # 学生用のダッシュボード（出欠一覧・登録画面）
  # GET /student
  def index
    @today = Time.zone.today
    # 今日の曜日に対応する時間割を取得 (月曜:1, 火曜:2...)
    # 日曜(0)の場合は月曜(1)のデータを仮で使うなど調整も可能ですが、ここでは空になります
    @periods = Period.where(weekday: @today.wday).order(:period_number)

    # 今日の日付で登録済みの出席記録を、period_idをキーとしてハッシュで取得
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

  private

  def attendance_params
    params.expect(attendance: %i[period_id status reason]).merge(date: Time.zone.today)
  end

  def check_student_role
    unless current_user&.student?
      redirect_to root_path, alert: '学生のみアクセスできます。'
    end
  end

end