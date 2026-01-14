require "test_helper"

class AttendanceSearchFormTest < ActiveSupport::TestCase
  # ===== バリデーションテスト =====

  test "year が必須" do
    form = AttendanceSearchForm.new(valid_search_params.merge(year: nil))
    assert_not form.valid?
    assert form.errors.added?(:year, :blank)
  end

  test "month が必須" do
    form = AttendanceSearchForm.new(valid_search_params.merge(month: nil))
    assert_not form.valid?
    assert form.errors.added?(:month, :blank)
  end

  test "day が必須" do
    form = AttendanceSearchForm.new(valid_search_params.merge(day: nil))
    assert_not form.valid?
    assert form.errors.added?(:day, :blank)
  end

  test "period_number が必須" do
    form = AttendanceSearchForm.new(valid_search_params.merge(period_number: nil))
    assert_not form.valid?
    assert form.errors.added?(:period_number, :blank)
  end

  test "enrollment_year が必須" do
    form = AttendanceSearchForm.new(valid_search_params.merge(enrollment_year: nil))
    assert_not form.valid?
    assert form.errors.added?(:enrollment_year, :blank)
  end

  test "無効な日付はエラー" do
    form = AttendanceSearchForm.new(
      valid_search_params.merge(
        month: 13,
      )
    )
    assert_not form.valid?
    assert_includes form.errors[:base], "無効な日付です。"
  end

  test "存在しない時限・曜日の組み合わせはエラー" do
    # 日曜日の1限は存在しない想定
    form = AttendanceSearchForm.new(
      valid_search_params.merge(
        year: 2025,
        month: 10,
        day: 19
      )
    )
    assert_not form.valid?
    assert_includes form.errors[:base], "指定された曜日・コマの授業が見つかりませんでした。"
  end

  # ===== search メソッドテスト =====

  test "有効なパラメータで search が成功する" do
    form = AttendanceSearchForm.new(valid_search_params)

    assert form.search, "検索が成功するべき: #{form.errors.full_messages}"
    assert_not_nil form.date
    assert_not_nil form.period
  end

  test "search で学生一覧が取得できる" do
    form = AttendanceSearchForm.new(valid_search_params)

    form.search
    assert_not_empty form.students, "学生一覧が取得できるべき"
    assert form.students.all?(&:student?), "全員が学生であるべき"
  end

  test "search で出席データが取得できる" do
    form = AttendanceSearchForm.new(valid_search_params)

    form.search
    assert_kind_of Hash, form.attendances
  end

  test "enrollment_year でフィルタできる" do
    form = AttendanceSearchForm.new(valid_search_params)

    form.search
    assert form.students.all? { |s| s.enrollment_year == 2024 }, "指定した入学年度の学生のみ取得されるべき"
  end

  test "生徒ユーザーでの検索結果が正しいこと（自分の全出欠が取得できる）" do
    student = users(:student_taro)
    form = AttendanceSearchForm.new(
      year: 2025,
      month: 10,
      day: 20,
      current_user: student
    )

    assert form.search, "検索が成功するべき: #{form.errors.full_messages}"

    # studentsは空であるべき（管理機能ではないため）
    assert_empty form.students, "生徒検索では students は空であるべき"

    # 出席データが取得できているか
    assert_not_empty form.attendances, "出席データが取得できるべき"
    assert_kind_of Hash, form.attendances

    # 自分のデータのみが含まれているか確認
    form.attendances.values.each do |attendance|
      assert_equal student.id, attendance.user_id
    end
  end

  private

  # 有効な検索パラメータ
  def valid_search_params
    {
      year: 2025,
      month: 10,
      day: 20,
      period_number: 1,
      enrollment_year: 2024,
      current_user: users(:admin_user)
    }
  end
end
