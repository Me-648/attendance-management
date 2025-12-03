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
Period.destroy_all
Attendance.destroy_all
Period.destroy_all
User.destroy_all
puts '削除完了'

# --- 1. 管理者アカウントの作成 ---
puts '1. 管理者アカウントを作成中...'
User.create!(
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'システム管理者',
  role: :admin,
  # 管理者のため、student_idとenrollment_yearはnil (NULL)
  student_id: nil,
  enrollment_year: nil 
)
puts '  -> admin@example.com (パスワード: password) 作成完了'

# --- 2. 時間割（Periods）データの作成 ---
puts '2. 時間割（Periods）データを作成中...'

# 各コマの開始時刻を定義
PERIOD_TIMES = [
  { period_number: 1, start_time: '09:30:00' },  # 9:30~11:10
  { period_number: 2, start_time: '11:20:00' },  # 11:20~13:00
  { period_number: 3, start_time: '13:45:00' }   # 13:45~15:25
]

# 月曜(1) 〜 木曜(4): 3コマ
(1..4).each do |weekday|
  PERIOD_TIMES.each do |p_data|
    Period.create!(
      period_number: p_data[:period_number],
      weekday: weekday,
      start_time: p_data[:start_time]
    )
  end
end

# 金曜(5): 2コマのみ
PERIOD_TIMES.take(2).each do |p_data|
  Period.create!(
    period_number: p_data[:period_number],
    weekday: 5,
    start_time: p_data[:start_time]
  )
end

puts "  -> 全#{Period.count}コマの時間割を作成完了"

# --- 3. 大量の学生アカウントを作成 ---
puts '3. 学生アカウントを作成中...'

# 2024年度入学生30名を作成
student_names = [
  '田中太郎', '田中花子', '田中', '田中',
  '佐藤一郎', '佐藤美咲', '佐藤健太', '佐藤',
  '鈴木次郎', '鈴木由美', '鈴木大輔', '鈴木',
  '高橋三郎', '高橋麻衣', '高橋拓也', '高橋',
  '伊藤四郎', '伊藤愛', '伊藤翔太', '伊藤',
  '渡辺五郎', '渡辺優子', '渡辺翔', '渡辺',
  '山本六郎', '山本真由', '山本健', '山本',
  '中村七郎', '中村彩', '中村', '中村'
]

students = []
student_names.each_with_index do |name, index|
  student = User.create!(
    email: "student#{index + 1}@example.com",
    password: 'password',
    password_confirmation: 'password',
    name: name,
    role: :student,
    student_id: "S2024#{(index + 1).to_s.rjust(4, '0')}",
    enrollment_year: 2024
  )
  students << student
end

puts "  -> #{students.count}名の学生アカウント作成完了"

# --- 4. 大量の出欠実績（Attendances）を作成 ---
puts '4. 出欠実績を作成中...'

# 2025年10月14日(火)のデータを作成
target_date = Date.new(2025, 10, 14) # 火曜日
tue_period = Period.find_by!(weekday: 2, period_number: 1) # 火曜1限

attendance_count = 0

students.each_with_index do |student, index|
  # ランダムに欠席者を4名程度作成（indexが3の倍数+1の場合）
  status = if [1, 7, 15, 23].include?(index)
    :absent
  else
    :attended
  end

  attendance = Attendance.new(
    user: student,
    period: tue_period,
    date: target_date,
    status: status
  )
  attendance.save(validate: false)
  attendance_count += 1
end

# 追加の出席データ（過去の日付でも数件作成）
students.sample(10).each do |student|
  mon_period = Period.find_by!(weekday: 1, period_number: 1)
  attendance = Attendance.new(
    user: student,
    period: mon_period,
    date: Date.new(2025, 10, 7),
    status: [:attended, :absent].sample
  )
  attendance.save(validate: false)
  attendance_count += 1
end

puts "  -> #{attendance_count}件の出欠実績作成完了"
puts '=================================================='
puts 'シードデータ投入完了！開発を開始できます。'
puts '管理者: admin@example.com / 学生: a@student.com (どちらもパスワード: password)'
puts '=================================================='