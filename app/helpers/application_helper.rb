module ApplicationHelper
  def flash_alert_class(type)
    case type.to_s
    when "notice"
      "bg-green-500"
    when "alert", "error"
      "bg-red-500"
    else
      "bg-blue-500"
    end
  end
end
