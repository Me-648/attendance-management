
module AttendancesHelper
  def attendance_badge_classes(status)
    return "inline-block px-3 py-1 rounded text-sm font-bold text-white bg-gray-400" if status.nil?

    base_classes = "inline-block px-3 py-1 rounded text-sm font-bold text-white"
    case status.to_sym
    when :attended
      "#{base_classes} bg-attended"
    when :absent
      "#{base_classes} bg-absent"
    when :late
      "#{base_classes} bg-late"
    when :officially_absent
      "#{base_classes} bg-officially-absent"
    else
      "#{base_classes} bg-gray-400"
    end
  end

  def attendance_label(status_key)
    return "未登録" if status_key.nil?

    case status_key.to_sym
    when :attended then "出席"
    when :absent then "欠席"
    when :late then "遅刻"
    when :officially_absent then "公欠"
    else "不明"
    end
  end
end
