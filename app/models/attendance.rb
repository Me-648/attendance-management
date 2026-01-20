class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :period

  # attended: 出席, absent: 欠席, late: 遅刻, officially_absent: 公欠
  enum :status, { attended: 0, absent: 1, late: 2, officially_absent: 3 }, prefix: true

  # 1人のユーザーは、1つの授業に1回しか出席登録できないようにします。
  validates :user_id, uniqueness: { scope: [ :period_id, :date ], message: "は既に登録済みです。" }

  # 出席登録可能な時間帯かどうかを検証するカスタムバリデーション
  validate :time_to_attend, on: :create, if: :status_attended?

  def time_to_attend
    return if period&.start_time.blank?

    # DBのstart_timeは日付が2000年1月1日になっているため、出席対象の日付に合わせる
    target_date = self.date || Date.current
    start_time_on_date = Time.zone.local(
      target_date.year,
      target_date.month,
      target_date.day,
      period.start_time.hour,
      period.start_time.min,
      period.start_time.sec
    )

    reception_start_time = start_time_on_date - 5.minutes
    reception_end_time = start_time_on_date

    # 現在時刻と比較
    current_time = Time.current

    if current_time < reception_start_time
      errors.add(:base, "出席の受付は授業開始5分前からです。")
    elsif current_time > reception_end_time
      errors.add(:base, "この授業の出席受付は終了しました。")
    end
  end

  # 特定ユーザーのステータス別集計を返す
  def self.stats_for_user(user_id)
    counts = where(user_id: user_id).group(:status).count
    {
      attended: counts["attended"] || 0,
      absent: counts["absent"] || 0,
      late: counts["late"] || 0,
      officially_absent: counts["officially_absent"] || 0,
      total: counts.values.sum
    }
  end
end
