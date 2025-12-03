class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  
  def index; end

  # 出欠一覧画面
  def attendance_list
    # パラメータのマッピング
    form_params = {
      year: params[:year],
      month: params[:month],
      day: params[:day],
      period_number: params[:period],
      enrollment_year: params[:enrollment_year]
    }
    
    @search_form = Admin::AttendanceSearchForm.new(form_params)
  
    if params[:year].present?
      if @search_form.search
        # 成功時はフォームから結果を取り出す
        @students = @search_form.students
        @attendances = @search_form.attendances
        @attended_count = @search_form.attended_count
        @absent_count = @search_form.absent_count
        @unrecorded_count = @search_form.unrecorded_count  # 追加
        
        # 未記録が多い場合に警告
        if @unrecorded_count > 0
          flash.now[:notice] = "#{@unrecorded_count}名の出席データがまだ記録されていません。"
        end
        
        # ビューで使う変数をセット
        @date = @search_form.date
        @period = @search_form.period
      else
        flash.now[:alert] = @search_form.errors.full_messages.join("\n")
        set_empty_results
      end
    else
      set_empty_results
    end
  end
  
  # 累計一覧画面（欠席者リスト）
  def absence_list
    @enrollment_year = params[:enrollment_year]
    
    # 学生を取得（入学年度でフィルタ可能）
    @students = User.student.order(:student_id)
    @students = @students.where(enrollment_year: @enrollment_year) if @enrollment_year.present?
    
    # 各学生の欠席回数を一括集計（N+1問題を解消）
    # デフォルト値を0にするため Hash.new(0) を使用
    @absence_counts = Hash.new(0).merge(Attendance.status_absent.group(:user_id).count)
  end

  # 欠席理由画面（新規追加）
  def absence_reason
    # URLパラメータからAttendance IDを取得
    @attendance = Attendance.find(params[:id])
    
    # 出席データに紐づく学生情報を取得
    @student = @attendance.user
    
    # 出席データに紐づく授業情報を取得
    @period = @attendance.period
    
    # セキュリティチェック: 欠席以外のデータはアクセス拒否
    unless @attendance.status == 'absent'
      redirect_to admin_root_path, alert: "欠席者のみアクセスできます。"
    end
  rescue ActiveRecord::RecordNotFound
    # 存在しないIDの場合
    redirect_to admin_root_path, alert: "出席データが見つかりませんでした。"
  end
  
  private
  
  def set_empty_results
    @students = []
    @attendances = {}
    @absent_count = 0
    @attended_count = 0
    @unrecorded_count = 0  # 追加
  end
  
  def check_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "管理者権限が必要です。"
    end
  end
end