class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :period

  # statusカラムをenum（列挙型）として定義します。
  # これにより、 :attended と書くだけで status に 0 を設定できます。
  # 0が出席　1が欠席
  enum status: { attended: 0, absent: 1}

  # 1人のユーザーは、1つの授業に1回しか出席登録できないようにします。
  validates :user_id, uniqueness: { scope: :period_id }

  # 出席登録可能な時間帯かどうかを検証するカスタムバリデーション
  validate :time_to_attend, if: :attended?

  private

  def time_to_attend
    # 関連する授業(period)とその開始時刻(start_time)が存在するかを確認
    return if period&.start_time.blank?

    # 現在時刻が、授業開始時刻の5分前より前の場合
    if Time.current < period.start_time - 5.minutes
      errors.add(:base, "出席の受付は授業開始5分前からです。")
    end
  end
end
