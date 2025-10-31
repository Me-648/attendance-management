class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :period
  validates :user_id, presence: true

  enum :status, { attended: 0, absent: 1 }

  validates :user_id, uniqueness: { scope: :period_id }
  validate :time_to_attend, if: :attended?

  private

  def time_to_attend
    return if period&.start_time.blank?
    if Time.current < period.start_time - 5.minutes
      errors.add(:base, "出席の受付は授業開始5分前からです。")
    end
  end
end
