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

    reception_start_time = period.start_time - 5.minutes
    reception_end_time = period.start_time

    # 現在時刻が、授業開始時刻の5分前より前の場合
    if Time.current < reception_start_time
      errors.add(:base, "出席の受付は授業開始5分前からです。")
    elsif Time.current > reception_end_time
      errors.add(:base, "この授業の出席受付は終了しました。")
    end
  end
end
