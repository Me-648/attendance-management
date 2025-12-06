require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  # ===== バリデーションテスト =====

  test "同じユーザー・時限・日付の組み合わせは重複登録できない" do
    existing = attendances(:taro_monday_first)

    duplicate = Attendance.new(
      user: existing.user,
      period: existing.period,
      date: existing.date,
      status: :attended
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "は既に登録済みです。"
  end

  test "同じユーザーでも日付が違えば登録できる" do
    existing = attendances(:taro_monday_first)

    new_attendance = Attendance.new(
      user: existing.user,
      period: existing.period,
      date: existing.date + 7.days,
      status: :attended
    )

    # time_to_attend バリデーションをスキップするため、status を absent に
    new_attendance.status = :absent
    assert new_attendance.valid?, "日付が違えば有効であるべき: #{new_attendance.errors.full_messages}"
  end

  test "同じユーザー・日付でも時限が違えば登録できる" do
    existing = attendances(:taro_monday_first)
    different_period = periods(:monday_second)

    new_attendance = Attendance.new(
      user: existing.user,
      period: different_period,
      date: existing.date,
      status: :absent
    )

    assert new_attendance.valid?, "時限が違えば有効であるべき: #{new_attendance.errors.full_messages}"
  end

  # ===== enum テスト =====

  test "status enum が正しく動作する" do
    attendance = attendances(:taro_monday_first)
    attendance.status = :attended
    assert attendance.status_attended?

    attendance.status = :absent
    assert attendance.status_absent?

    attendance.status = :late
    assert attendance.status_late?

    attendance.status = :officially_absent
    assert attendance.status_officially_absent?
  end

  # ===== 関連テスト =====

  test "attendance は user に属する" do
    attendance = attendances(:taro_monday_first)
    assert_respond_to attendance, :user
    assert_kind_of User, attendance.user
  end

  test "attendance は period に属する" do
    attendance = attendances(:taro_monday_first)
    assert_respond_to attendance, :period
    assert_kind_of Period, attendance.period
  end

  # ===== time_to_attend バリデーションテスト =====

  test "出席受付時間外（授業開始5分より前）は出席登録できない" do
    period = periods(:monday_first)
    user = users(:student_hanako)

    # 現在時刻を授業開始10分前に設定
    travel_to period.start_time - 10.minutes do
      attendance = Attendance.new(
        user: user,
        period: period,
        date: Date.current,
        status: :attended
      )

      assert_not attendance.valid?
      assert_includes attendance.errors[:base], "出席の受付は授業開始5分前からです。"
    end
  end

  test "出席受付時間外（授業開始後）は出席登録できない" do
    period = periods(:monday_first)
    user = users(:student_hanako)

    # 現在時刻を授業開始1分後に設定
    travel_to period.start_time + 1.minute do
      attendance = Attendance.new(
        user: user,
        period: period,
        date: Date.current,
        status: :attended
      )

      assert_not attendance.valid?
      assert_includes attendance.errors[:base], "この授業の出席受付は終了しました。"
    end
  end

  test "出席受付時間内（授業開始5分前〜開始時刻）は出席登録できる" do
    period = periods(:monday_first)
    user = users(:student_hanako)

    # 現在時刻を授業開始3分前に設定
    travel_to period.start_time - 3.minutes do
      attendance = Attendance.new(
        user: user,
        period: period,
        date: Date.current,
        status: :attended
      )

      assert attendance.valid?, "受付時間内なら有効であるべき: #{attendance.errors.full_messages}"
    end
  end

  test "欠席の場合は time_to_attend バリデーションが適用されない" do
    period = periods(:monday_first)
    user = users(:student_hanako)

    # 授業開始10分前でも欠席登録は可能
    travel_to period.start_time - 10.minutes do
      attendance = Attendance.new(
        user: user,
        period: period,
        date: Date.current,
        status: :absent
      )

      assert attendance.valid?, "欠席なら時間制限なしで有効であるべき: #{attendance.errors.full_messages}"
    end
  end
end
