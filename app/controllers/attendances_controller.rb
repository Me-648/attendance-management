class AttendancesController < ApplicationController
  # 学生ロール以外はアクセスできないようにする
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

  # 出欠登録処理
  # POST /student/attendances
  def create
    # パラメータからperiod_idを取得
    # find は見つからない場合にエラーを発生させます
    period = Period.find(attendance_params[:period_id])
    
    # find_or_initialize_by で、該当の出欠記録があれば取得、なければ新規作成
    @attendance = current_user.attendances.find_or_initialize_by(
      period: period,
      date: Time.zone.today
    )

    # パラメータから送られてきたステータスをセット
    @attendance.status = attendance_params[:status]

    if @attendance.save
      # 保存成功時
      redirect_to student_root_path, notice: "#{period.period_number}限目の「#{@attendance.status_i18n}」を受け付けました。"
    else
      # 保存失敗時（バリデーションエラーなど）
      # エラーメッセージをフラッシュに格納してリダイレクト
      redirect_to student_root_path, alert: @attendance.errors.full_messages.join(", ")
    end
  end

  private

  # Strong Parameters
  def attendance_params
    params.require(:attendance).permit(:period_id, :status)
  end

  # 学生ロールかどうかをチェック
  def check_student_role
    # is_admin? はUserモデルに実装されている想定
    if current_user.is_admin?
      redirect_to admin_root_path, alert: "管理者権限ではアクセスできません。"
    end
  end
end
