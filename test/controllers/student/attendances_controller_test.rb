require "test_helper"

module Student
  class AttendancesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @student = users(:student_taro)
      @admin = users(:admin_user)
      @period = periods(:monday_first)
    end

    # ===== 認証テスト =====

    test "未ログインユーザーはアクセスできない" do
      get student_root_path
      assert_response :redirect
    end

    # ===== create アクションテスト =====

    test "出席登録が成功する" do
      sign_in @student
      new_period = periods(:tuesday_first)

      # 受付時間内に設定
      travel_to new_period.start_time - 3.minutes do
        assert_difference "Attendance.count", 1 do
          post student_attendances_path, params: {
            attendance: {
              period_id: new_period.id,
              status: "attended"
            }
          }, headers: { "HTTP_ACCEPT" => "text/html" }
        end

        assert_redirected_to student_root_path
        assert_equal "出席が記録されました。", flash[:notice]
      end
    end
  end
end
