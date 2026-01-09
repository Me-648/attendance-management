# ==============================================================================
# 出欠データの内訳（各コマ30人分）
# ==============================================================================
#
# ■ 月曜日（2025/12/1）
#   1限目: 出席22名, 欠席3名, 遅刻3名, 公欠2名
#   2限目: 出席24名, 欠席2名, 遅刻2名, 公欠2名
#   3限目: 出席20名, 欠席4名, 遅刻4名, 公欠2名
#
# ■ 火曜日（2025/12/2）
#   1限目: 出席23名, 欠席2名, 遅刻3名, 公欠2名
#   2限目: 出席25名, 欠席2名, 遅刻2名, 公欠1名
#   3限目: 出席21名, 欠席3名, 遅刻4名, 公欠2名
#
# ■ 水曜日（2025/12/3）
#   1限目: 出席24名, 欠席2名, 遅刻2名, 公欠2名
#   2限目: 出席22名, 欠席3名, 遅刻3名, 公欠2名
#   3限目: 出席23名, 欠席2名, 遅刻3名, 公欠2名
#
# ■ 金曜日（2025/12/5）※2コマのみ
#   1限目: 出席25名, 欠席2名, 遅刻2名, 公欠1名
#   2限目: 出席23名, 欠席3名, 遅刻2名, 公欠2名
#
# ------------------------------------------------------------------------------
# 合計出欠レコード数: 330件（30人 × 11コマ）
#
# 欠席理由:
#   - 欠席: 体調不良のため, 通院のため, 家庭の事情
#   - 遅刻: 電車遅延のため, 寝坊のため, バス遅延のため
#   - 公欠: 就職活動のため, 公式大会参加のため, 忌引きのため
# ==============================================================================

# --- 1. 管理者アカウントの作成 ---
User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.name = 'システム管理者'
  user.role = :admin
  user.student_id = 'admin'
  user.enrollment_year = 0
end

# --- 2. 時間割（Periods）データの作成 ---
PERIOD_TIMES = [
  { period_number: 1, start_time: '09:30:00' },
  { period_number: 2, start_time: '11:20:00' },
  { period_number: 3, start_time: '13:45:00' }
].freeze

(1..5).each do |weekday| # 1:月曜 〜 5:金曜
  periods_to_create = PERIOD_TIMES

  # 金曜日(5)は2コマのみ
  if weekday == 5
    periods_to_create = PERIOD_TIMES.reject { |p| p[:period_number] == 3 }
  end

  periods_to_create.each do |p_data|
    Period.find_or_create_by!(
      period_number: p_data[:period_number],
      weekday: weekday
    ) do |period|
      period.start_time = p_data[:start_time]
    end
  end
end

# --- 3. 30人分の学生アカウントの作成 ---
LAST_NAMES = %w[田中 佐藤 鈴木 高橋 伊藤 渡辺 山本 中村 小林 加藤
                吉田 山田 松本 井上 木村 林 斎藤 清水 山口 森].freeze
FIRST_NAMES = %w[太郎 花子 一郎 次郎 三郎 美咲 陽子 健太 大輔 翔太
                愛 結衣 葵 蓮 悠真 陽菜 凛 樹 湊 朝陽].freeze

students = []
30.times do |i|
  student_number = format('%02d', i + 1)
  enrollment_year = [ 2023, 2024, 2025 ].sample
  last_name = LAST_NAMES[i % LAST_NAMES.size]
  first_name = FIRST_NAMES[i % FIRST_NAMES.size]

  student = User.find_or_create_by!(email: "student#{student_number}@example.com") do |user|
    user.password = 'password'
    user.password_confirmation = 'password'
    user.name = "#{last_name}#{first_name}"
    user.role = :student
    user.student_id = "S#{enrollment_year}#{student_number}"
    user.enrollment_year = enrollment_year
  end
  students << student
end

# --- 4. 出欠実績（Attendances）の作成 ---
# 固定日付のマッピング（weekday => date）
DATES = {
  1 => Date.new(2025, 12, 1), # 月曜日
  2 => Date.new(2025, 12, 2), # 火曜日
  3 => Date.new(2025, 12, 3), # 水曜日
  5 => Date.new(2025, 12, 5)  # 金曜日
}.freeze

# 欠席理由
ABSENT_REASONS = {
  absent: %w[体調不良のため 通院のため 家庭の事情],
  late: %w[電車遅延のため 寝坊のため バス遅延のため],
  officially_absent: %w[就職活動のため 公式大会参加のため 忌引きのため]
}.freeze

# 明示的に出欠データを定義
# [weekday, period_number] => { attended:, absent:, late:, officially_absent: }
ATTENDANCE_DISTRIBUTION = {
  # 月曜日
  [ 1, 1 ] => { attended: 22, absent: 3, late: 3, officially_absent: 2 },
  [ 1, 2 ] => { attended: 24, absent: 2, late: 2, officially_absent: 2 },
  [ 1, 3 ] => { attended: 20, absent: 4, late: 4, officially_absent: 2 },
  # 火曜日
  [ 2, 1 ] => { attended: 23, absent: 2, late: 3, officially_absent: 2 },
  [ 2, 2 ] => { attended: 25, absent: 2, late: 2, officially_absent: 1 },
  [ 2, 3 ] => { attended: 21, absent: 3, late: 4, officially_absent: 2 },
  # 水曜日
  [ 3, 1 ] => { attended: 24, absent: 2, late: 2, officially_absent: 2 },
  [ 3, 2 ] => { attended: 22, absent: 3, late: 3, officially_absent: 2 },
  [ 3, 3 ] => { attended: 23, absent: 2, late: 3, officially_absent: 2 },
  # 金曜日（2コマのみ）
  [ 5, 1 ] => { attended: 25, absent: 2, late: 2, officially_absent: 1 },
  [ 5, 2 ] => { attended: 23, absent: 3, late: 2, officially_absent: 2 }
}.freeze

# 各コマの出欠データを作成
ATTENDANCE_DISTRIBUTION.each do |(weekday, period_number), distribution|
  period = Period.find_by!(weekday: weekday, period_number: period_number)
  date = DATES[weekday]

  student_index = 0
  %i[attended absent late officially_absent].each do |status|
    distribution[status].times do
      reason = status == :attended ? nil : ABSENT_REASONS[status].sample

      Attendance.new(
        user: students[student_index],
        period: period,
        date: date,
        status: status,
        reason: reason
      ).save(validate: false)

      student_index += 1
    end
  end
end
