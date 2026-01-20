module Student
  module AttendancesHelper
    def attendance_status_classes(is_selected, status_key, is_reception_active = true)
      status_sym = status_key.to_sym
      base_classes = "attendance-status"

      if is_selected
        case status_sym
        when :attended
          "#{base_classes} bg-attended text-white border-attended-dark hover:bg-attended-dark"
        when :absent
          "#{base_classes} bg-absent text-white border-absent-dark hover:bg-absent-dark"
        when :late
          "#{base_classes} bg-late text-white border-late-dark hover:bg-late-dark"
        when :officially_absent
          "#{base_classes} bg-officially-absent text-white border-officially-absent-dark hover:bg-officially-absent-dark"
        else
          "#{base_classes} bg-gray-100 text-gray-400 border-gray-200 cursor-not-allowed"
        end
      else
        # 未選択の場合
        # 出席ボタンかつ受付時間外ならグレーアウト
        if status_sym == :attended && !is_reception_active
            "#{base_classes} bg-gray-100 text-gray-400 border-gray-200 cursor-not-allowed"
        else
            # 未選択だが押せる状態 (通常状態)
            hover_classes = case status_sym
            when :attended
                              "hover:bg-attended-bg hover:border-attended"
            when :absent
                              "hover:bg-absent-bg hover:border-absent"
            when :late
                              "hover:bg-late-bg hover:border-late"
            when :officially_absent
                              "hover:bg-officially-absent-bg hover:border-officially-absent"
            else
                              "hover:bg-neutral-bg"
            end

            "#{base_classes} bg-white text-gray-700 border-neutral-border #{hover_classes}"
        end
      end
    end

    def attendance_disabled?(period, status_key)
      # 出席ボタンは、受付時間外なら押せない
      if status_key.to_sym == :attended
        !period.reception_active?
      else
        false
      end
    end
  end
end
