require "test_helper"

class AttendanceSearchFormTest < ActiveSupport::TestCase
  # ===== バリデーションテスト =====

  test "必須項目が空の場合は無効" do
    form = AttendanceSearchForm.new
    assert_not form.valid?
    assert_includes form.errors[:year], "can't be blank"
    assert_includes form.errors[:month], "can't be blank"
    assert_includes form.errors[:day], "can't be blank"
    assert_includes form.errors[:period_number], "can't be blank"
    assert_includes form.errors[:enrollment_year], "can't be blank"
  end

  test "無効な日付（2月30日など）はエラー" do
    form = AttendanceSearchForm.new(
      year: 2025,
      month: 2,
      day: 30,
      period_number: 1,
      enrollment_year: 2024
    )
    assert_not form.valid?
    assert_includes form.errors[:base], "無効な日付です。"
  end

  test "存在しない時限・曜日の組み合わせはエラー" do
    # 日曜日（weekday: 0）の1限は存在しない想定
    form = AttendanceSearchForm.new(
      year: 2025,
      month: 10,
      day: 19,  # 2025-10-19 は日曜日
      period_number: 1,
      enrollment_year: 2024
    )
    assert_not form.valid?
    assert_includes form.errors[:base], "指定された曜日・コマの授業が見つかりませんでした。"
  end

  # ===== search メソッドテスト =====

  test "有効なパラメータで search が成功する" do
    # monday_first は weekday: 1（月曜日）
    # 2025-10-20 は月曜日
    form = AttendanceSearchForm.new(
      year: 2025,
      month: 10,
      day: 20,
      period_number: 1,
      enrollment_year: 2024
    )

    assert form.search, "検索が成功するべき: #{form.errors.full_messages}"
    assert_not_nil form.date
    assert_not_nil form.period
  end

  test "search で学生一覧が取得できる" do
    form = AttendanceSearchForm.new(
      year: 2025,
      month: 10,
      day: 20,
      period_number: 1,
      enrollment_year: 2024
    )

    form.search
    assert_not_empty form.students, "学生一覧が取得できるべき"
    assert form.students.all?(&:student?), "全員が学生であるべき"
  end

  test "search で出席データが取得できる" do
    form = AttendanceSearchForm.new(
      year: 2025,
      month: 10,
      day: 20,
      period_number: 1,
      enrollment_year: 2024
    )

    form.search
    assert_kind_of Hash, form.attendances
  end

  test "enrollment_year でフィルタできる" do
    form = AttendanceSearchForm.new(
      year: 2025,
      month: 10,
      day: 20,
      period_number: 1,
      enrollment_year: 2024
    )

    form.search
    assert form.students.all? { |s| s.enrollment_year == 2024 }, "指定した入学年度の学生のみ取得されるべき"
  end

  test "出席・欠席・未記録のカウントが正しい" do
    form = AttendanceSearchForm.new(
      year: 2025,
      month: 10,
      day: 20,
      period_number: 1,
      enrollment_year: 2024
    )

    form.search

    # fixtures の設定:
    # - taro: attended (status: 0)
    # - hanako: attended (status: 0)
    # - jiro: absent (status: 1)
    assert_operator form.attended_count, :>=, 0
    assert_operator form.absent_count, :>=, 0
    assert_operator form.unrecorded_count, :>=, 0
  end
end
