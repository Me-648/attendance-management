class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  
  def index; end

  # 出欠一覧画面
  def attendance_list
    # パラメータのマッピング（viewのparam名とform objectの属性名を合わせる）
    form_params = {
      year: params[:year],
      month: params[:month],
      day: params[:day],
      period_number: params[:period],
      enrollment_year: params[:enrollment_year]
    }
    
    @search_form = Admin::AttendanceSearchForm.new(form_params)

    # 検索実行（パラメータが空の場合はバリデーションエラーになるが、初期表示ではエラーを出さないように制御しても良い）
    if params[:year].present? # 何かしら検索条件がある場合のみ実行
      if @search_form.search
        # 成功時はフォームから結果を取り出す
        @students = @search_form.students
        @attendances = @search_form.attendances
        @attended_count = @search_form.attended_count
        @absent_count = @search_form.absent_count
        
        # ビューで使う変数をセット（互換性のため）
        @date = @search_form.date
        @period = @search_form.period
      else
        flash.now[:alert] = @search_form.errors.full_messages.join("\n")
        set_empty_results
      end
    else
      # 初期表示
      set_empty_results
      flash.now[:alert] = "検索条件を入力してください。" unless params[:commit].nil? # 検索ボタン押下時のみ表示したい場合
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
  
  private
  
  def set_empty_results
    @students = []
    @attendances = {}
    @absent_count = 0
    @attended_count = 0
  end
  
  def check_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "管理者権限が必要です。"
    end
  end
end