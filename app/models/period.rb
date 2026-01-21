class Period < ApplicationRecord
  has_many :attendances, dependent: :destroy
  has_many :users, through: :attendances

  # 出席受付時間内かどうかを判定するメソッド
  def reception_active?
    return false if start_time.blank?

    # DBのstart_timeは日付が2000年1月1日になっているため、今日の日付に合わせる
    now = Time.current
    today_start_time = now.change(hour: start_time.hour, min: start_time.min, sec: start_time.sec)

    reception_start_time = today_start_time - 5.minutes
    reception_end_time = today_start_time

    now.between?(reception_start_time, reception_end_time)
  end
end
