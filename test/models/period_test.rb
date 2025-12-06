require "test_helper"

class PeriodTest < ActiveSupport::TestCase
  # ===== 関連テスト =====

  test "period は複数の attendances を持てる" do
    period = periods(:monday_first)
    assert_respond_to period, :attendances
    assert_kind_of ActiveRecord::Associations::CollectionProxy, period.attendances
  end

  test "period は attendances を通じて users を持てる" do
    period = periods(:monday_first)
    assert_respond_to period, :users
  end

  test "period を削除すると関連する attendances も削除される" do
    period = periods(:monday_first)
    attendance_count = period.attendances.count

    assert_difference "Attendance.count", -attendance_count do
      period.destroy
    end
  end

  # ===== 属性テスト =====

  test "period_number と weekday と start_time を持つ" do
    period = periods(:monday_first)
    assert_equal 1, period.period_number
    assert_equal 1, period.weekday
    assert_not_nil period.start_time
  end
end
