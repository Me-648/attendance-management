module AttendancesHelper
  def attendances_path
    current_user.admin? ? admin_attendances_by_period_path : "生徒用パス"
  end
end
