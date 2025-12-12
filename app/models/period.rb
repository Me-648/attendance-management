class Period < ApplicationRecord
  has_many :attendances, dependent: :destroy
  has_many :users, through: :attendances

  # ビューで曜日と時限を分かりやすく表示するためのメソッド
  def full_name
    # I18n (国際化) を使って曜日名を取得
    "#{I18n.t('date.day_names')[weekday]} #{period_number}限"
  end

  # 出席受付時間内かどうかを判定するメソッド
  def reception_active?
    return false if start_time.blank?

    reception_start_time = start_time - 5.minutes
    reception_end_time = start_time
    Time.current.between?(reception_start_time, reception_end_time)
  end
end
