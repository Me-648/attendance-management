# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 開発環境をクリーンに保つため、データを全て削除
puts '既存データを全て削除します...'
Attendance.destroy_all
Period.destroy_all
User.destroy_all
puts '削除完了'

# --- 権限とステータスの定義（定数） ---
ADMIN_ROLE = 1
STUDENT_ROLE = 0
ATTENDANCE_STATUS = 0 # 出席
ABSENCE_STATUS = 1  # 欠席

# --- 1. 管理者アカウントの作成 ---
puts '1. 管理者アカウントを作成中...'
User.create!(
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'システム管理者',
  role: ADMIN_ROLE,
  # 管理者のため、student_idとenrollment_yearはnil (NULL)
  student_id: nil,
  enrollment_year: nil 
)
puts '  -> admin@example.com (パスワード: password) 作成完了'

# --- 2. 時間割（Periods）データの作成 ---
# 月曜(1)から金曜(5)までのコマを定義
puts '2. 時間割（Periods）データを作成中...'
PERIOD_TIMES = [
  { period_number: 1, start_time: '09:00:00' },
  { period_number: 2, start_time: '10:40:00' },
  { period_number: 3, start_time: '13:00:00' }
]

(1..5).each do |weekday| # 1:月曜 〜 5:金曜
  periods_to_create = PERIOD_TIMES
  
  # 金曜日(5)は2コマのみ
  if weekday == 5
    periods_to_create = PERIOD_TIMES.reject { |p| p[:period_number] == 3 }
  end

  periods_to_create.each do |p_data|
    Period.create!(
      period_number: p_data[:period_number],
      weekday: weekday,
      start_time: p_data[:start_time]
    )
  end
end
puts "  -> 全#{Period.count}コマの時間割を作成完了"

# --- 3. サンプル学生アカウントの作成 ---
puts '3. サンプル学生アカウントを作成中...'
student_a = User.create!(
  email: 'a@student.com',
  password: 'password',
  password_confirmation: 'password',
  name: '田中太郎 (2025)',
  role: STUDENT_ROLE,
  student_id: 'A1000001',
  enrollment_year: 2025 
)
student_b = User.create!(
  email: 'b@student.com',
  password: 'password',
  password_confirmation: 'password',
  name: '佐藤花子 (2024)',
  role: STUDENT_ROLE,
  student_id: 'B2000002',
  enrollment_year: 2024
)
puts '  -> サンプル学生アカウント作成完了'

# --- 4. サンプル出欠実績（Attendances）の作成 ---
puts '4. サンプル出欠実績を作成中...'
# 月曜1限目（ID: 1）を取得
mon_1st_period = Period.find_by!(weekday: 1, period_number: 1)
# 金曜2限目（ID: 11 - ※連番の場合）を取得
fri_2nd_period = Period.find_by!(weekday: 5, period_number: 2)

# 田中太郎の過去の出欠を作成
Attendance.create!(
  user: student_a,
  period: mon_1st_period,
  date: Date.today.ago(7.days), # 1週間前の月曜日
  status: ATTENDANCE_STATUS,
  reason: nil
)
Attendance.create!(
  user: student_a,
  period: fri_2nd_period,
  date: Date.today.ago(3.days), # 過去の金曜日
  status: ABSENCE_STATUS,
  reason: '体調不良のため' # 欠席理由記入欄(ID:7)のテスト用
)

# 佐藤花子の過去の出欠を作成
Attendance.create!(
  user: student_b,
  period: mon_1st_period,
  date: Date.today.ago(7.days),
  status: ABSENCE_STATUS,
  reason: '親族の法事'
)

puts "  -> サンプル出欠実績 #{Attendance.count}件作成完了"
puts '=================================================='
puts 'シードデータ投入完了！開発を開始できます。'
puts '管理者: admin@example.com / 学生: a@student.com (どちらもパスワード: password)'
puts '=================================================='