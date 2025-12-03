class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  
  def index; end

  def attendance_list
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
        @students = @search_form.students
        @attendances = @search_form.attendances
        @attended_count = @search_form.attended_count
        @absent_count = @search_form.absent_count
        @unrecorded_count = @search_form.unrecorded_count
        
        if @unrecorded_count > 0
          flash.now[:notice] = "#{@unrecorded_count}名の出席データがまだ記録されていません。"
        end
        
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
  
  def absence_list
    @enrollment_year = params[:enrollment_year]
    
    @students = User.student.order(:student_id)
    @students = @students.where(enrollment_year: @enrollment_year) if @enrollment_year.present?
    
    @absence_counts = Hash.new(0).merge(Attendance.status_absent.group(:user_id).count)
  end
  
  def absence_reason
    @attendance = Attendance.find(params[:id])
    @student = @attendance.user
    @period = @attendance.period
    
    unless @attendance.status == 'absent'
      redirect_to admin_root_path, alert: "欠席者のみアクセスできます。"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_root_path, alert: "出席データが見つかりませんでした。"
  end
  
  # 累計画面（新規追加）
  def student_total
    # 学生情報を取得
    @student = User.find(params[:id])
    
    # 学生でない場合はエラー
    unless @student.student?
      redirect_to admin_root_path, alert: "学生情報が見つかりませんでした。"
      return
    end
    
    # その学生の全出席データを取得
    attendances = Attendance.where(user_id: @student.id)
    
    # 出席数を集計
    @attended_count = attendances.status_attended.count
    
    # 欠席数を集計
    @absent_count = attendances.status_absent.count
    
    # 遅刻数を集計
    @late_count = attendances.status_late.count
    
    # 公欠数を集計
    @officially_absent_count = attendances.status_officially_absent.count
    
    # 合計授業数（出席データがある授業の数）
    @total_count = attendances.count
    
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_root_path, alert: "学生情報が見つかりませんでした。"
  end
  
  private
  
  def set_empty_results
    @students = []
    @attendances = {}
    @absent_count = 0
    @attended_count = 0
    @unrecorded_count = 0
  end
  
  def check_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "管理者権限が必要です。"
    end
  end
end