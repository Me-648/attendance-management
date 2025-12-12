class AttendanceSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :year, :integer
  attribute :month, :integer
  attribute :day, :integer
  attribute :period_number, :integer
  attribute :enrollment_year, :integer

  validates :year, :month, :day, :period_number, :enrollment_year, presence: true
  validate :validate_date
  validate :validate_period

  # 未記録数を追加
  attr_reader :date, :period, :students, :attendances,
              :attended_count, :absent_count, :unrecorded_count

  def initialize(attributes = {})
    super
    @students = []
    @attendances = {}
    @attended_count = 0
    @absent_count = 0
    @unrecorded_count = 0
  end

  # 出欠データを検索
  def search
    return false unless valid?

    # 1. 学生取得
    @students = User.student.where(enrollment_year: enrollment_year).order(:student_id).to_a

    # 2. 出欠データ取得
    if period_number != 0
      student_ids = @students.map(&:id)
      attendances_list = Attendance.where(period_id: @period.id, date: @date, user_id: student_ids).to_a
      @attendances = attendances_list.index_by(&:user_id)

      # 3. 集計
      @attended_count = attendances_list.count { |a| a.status == "attended" }
      @absent_count = attendances_list.count { |a| a.status == "absent" }
      @unrecorded_count = @students.count - attendances_list.count
    else
      # 生徒側で検索した場合、全コマ分の出欠データを取得
      @attendances = Attendance.where(user_id: current_user, date: @date).index_by(&:period_id)
    end

    true
  end

  private

  def validate_date
    return if year.blank? || month.blank? || day.blank?
    begin
      @date = Date.new(year, month, day)
    rescue Date::Error
      errors.add(:base, "無効な日付です。")
    end
  end

  def validate_period
    return unless @date

    return if period_number.to_i == 0

    weekday = @date.cwday
    @period = Period.find_by(weekday: weekday, period_number: period_number)

    unless @period
      errors.add(:base, "指定された曜日・コマの授業が見つかりませんでした。")
    end
  end
end
