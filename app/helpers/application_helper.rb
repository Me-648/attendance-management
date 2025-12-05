module ApplicationHelper
  # 出席登録が可能な時間帯かを判定する
  # @param period [Period] 時間割オブジェクト
  # @return [Boolean] 登録可能な場合はtrue
  def attendance_registrable?(period)
    # 授業開始5分前から授業開始時刻までの間を許可
    # このロジックは app/models/attendance.rb のバリデーションと合わせておく
    now = Time.current
    start_time = period.start_time
    now.between?(start_time - 5.minutes, start_time)
  end
end
