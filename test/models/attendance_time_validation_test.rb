require "test_helper"

class AttendanceTimeValidationTest < ActiveSupport::TestCase
  test "time_to_attend validation works correctly" do
    user = users(:student_taro)
    period = periods(:monday_first)
    # Set start_time explicitly
    period.update!(start_time: "09:00:00")

    date = Date.today + 1.week # Use a future date

    # 1. Too early (8:54:59) -> >5 mins before
    travel_to Time.zone.local(date.year, date.month, date.day, 8, 54, 59) do
      att = Attendance.new(user: user, period: period, date: date, status: :attended)
      assert_not att.valid?, "Should be invalid before 5 mins range"
      assert_includes att.errors[:base], "出席の受付は授業開始5分前からです。"
    end

    # 2. Just right (8:55:00) -> 5 mins before
    travel_to Time.zone.local(date.year, date.month, date.day, 8, 55, 0) do
      att = Attendance.new(user: user, period: period, date: date, status: :attended)
      assert att.valid?, "Should be valid at exactly 5 mins before: #{att.errors.full_messages}"
    end

    # 3. Just before deadline (9:00:00)
    travel_to Time.zone.local(date.year, date.month, date.day, 9, 0, 0) do
      att = Attendance.new(user: user, period: period, date: date, status: :attended)
      assert att.valid?, "Should be valid at exactly start time"
    end

    # 4. Too late (9:00:01)
    travel_to Time.zone.local(date.year, date.month, date.day, 9, 0, 1) do
      att = Attendance.new(user: user, period: period, date: date, status: :attended)
      assert_not att.valid?, "Should be invalid after start time"
      assert_includes att.errors[:base], "この授業の出席受付は終了しました。"
    end
  end
end
