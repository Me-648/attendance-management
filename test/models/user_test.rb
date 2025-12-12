require "test_helper"

class UserTest < ActiveSupport::TestCase
  # ===== バリデーションテスト =====

  test "学生は student_id が必須" do
    user = User.new(
      name: "テスト学生",
      role: :student,
      email: "test@example.com",
      password: "password123",
      enrollment_year: 2024
    )
    assert_not user.valid?
    assert_includes user.errors[:student_id], "can't be blank"
  end

  test "学生は enrollment_year が必須" do
    user = User.new(
      name: "テスト学生",
      role: :student,
      email: "test@example.com",
      password: "password123",
      student_id: "S9999999"
    )
    assert_not user.valid?
    assert_includes user.errors[:enrollment_year], "can't be blank"
  end

  test "管理者も student_id と enrollment_year が必須" do
    user = User.new(
      name: "テスト管理者",
      role: :admin,
      email: "admin_test@example.com",
      password: "password123"
    )
    assert_not user.valid?
    assert_includes user.errors[:student_id], "can't be blank"
    assert_includes user.errors[:enrollment_year], "can't be blank"
  end

  test "student_id は一意でなければならない" do
    existing_user = users(:student_taro)
    user = User.new(
      name: "重複学生",
      role: :student,
      email: "duplicate@example.com",
      password: "password123",
      student_id: existing_user.student_id,
      enrollment_year: 2024
    )
    assert_not user.valid?
    assert_includes user.errors[:student_id], "has already been taken"
  end

  test "email は一意でなければならない" do
    existing_user = users(:student_taro)
    user = User.new(
      name: "重複メール",
      role: :student,
      email: existing_user.email,
      password: "password123",
      student_id: "S9999999",
      enrollment_year: 2024
    )
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  # ===== enum テスト =====

  test "role enum が正しく動作する" do
    student = users(:student_taro)
    admin = users(:admin_user)

    assert student.student?
    assert_not student.admin?

    assert admin.admin?
    assert_not admin.student?
  end

  # ===== 関連テスト =====

  test "学生は複数の出席記録を持てる" do
    student = users(:student_taro)
    assert_respond_to student, :attendances
    assert_kind_of ActiveRecord::Associations::CollectionProxy, student.attendances
  end
end
