class Admin::UsersController < ApplicationController
  before_action :check_admin

  def index
    # 検索パラメータを受け取り、不要なものを除外
    @search_params = params.permit(:year, :month, :day, :period, :enrollment_year)

    # ----------------------------------------------------
    # 1. 出欠一覧の検索と取得
    # ----------------------------------------------------
    
    @target_users = User.where(role: :student)
    if @search_params[:enrollment_year].present?
      @target_users = @target_users.where(enrollment_year: @search_params[:enrollment_year])
    end

    target_date = date_from_params(@search_params)
    target_period = @search_params[:period].presence

    @attendances_by_student = {}
    @periods = [] # 修正：デフォルトを空の配列に

    if target_date.present?
      attendances = Attendance.where(user: @target_users, date: target_date)
      
      if target_period.present?
         target_periods = Period.where(period_number: target_period)
         attendances = attendances.where(period: target_periods)
      end
      
      attendances.each do |att|
        @attendances_by_student[att.user_id] ||= {}
        @attendances_by_student[att.user_id][att.period_id] = att
      end

      # 🚨 追記するデバッグコード (確認後、削除してください)
      Rails.logger.debug "--- [Attendance Debug] ---"
      Rails.logger.debug "Target Date: #{target_date}"
      Rails.logger.debug "Found Attendance records count: #{attendances.count}"
      Rails.logger.debug "@attendances_by_student: #{@attendances_by_student.inspect}"
      Rails.logger.debug "--------------------------"
      # -----------------------------------------------

      # 🚨 重要な修正点：検索した日付の曜日に期間を絞り込む
      target_weekday = target_date.wday # 0:日曜, 1:月曜, ...
      @periods = Period.where(weekday: target_weekday).order(:period_number)
      
      @display_date = target_date
    else
      @display_date = nil
    end

    # ----------------------------------------------------
    # 2. 累計一覧のデータ準備 (Task 3)
    # ----------------------------------------------------
    # 累計一覧は、後続のタスクで集計ロジックを実装します。
    # 現状は、@target_usersを使って学生のリストを表示する基盤として利用します。
  end

  private
  
  # 年/月/日パラメータからDateオブジェクトを作成する
  def date_from_params(search_params)
    year = search_params[:year].to_i
    month = search_params[:month].to_i
    day = search_params[:day].to_i

    return nil unless year.positive? && month.positive? && day.positive?

    begin
      Date.new(year, month, day)
    rescue ArgumentError # 無効な日付（例: 2月30日）の場合
      nil
    end
  end

  def check_admin
    # ... (既存のコードは変更なし) ...
    unless current_user.is_admin? 
      flash[:alert] = "管理者権限が必要です。"
      redirect_to root_path
    end
  end
end