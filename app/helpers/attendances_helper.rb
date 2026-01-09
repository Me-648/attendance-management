module AttendancesHelper
  def attendances_path
    current_user.admin? ? admin_attendances_by_period_path : "生徒用パス"
  end

  def attendance_stats(search_form)
    attendances_values = search_form.attendances.values
    students_count = search_form.students.size

    {
      attended: attendances_values.count(&:status_attended?),
      absent: attendances_values.count(&:status_absent?),
      unrecorded: students_count - search_form.attendances.size
    }
  end
end
