class AttendanceSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :year, :integer
  attribute :month, :integer
  attribute :day, :integer
  attribute :period_number, :integer
  attribute :enrollment_year, :integer

  validates :year, :month, :day, :period_number, presence: true
  validate :validate_date
  validate :validate_period

  # 未記録数を追加
  attr_reader :date, :period, :students, :attendances, 
              :attended_count, :absent_count, :unrecorded_count

  period_number = 0

  def initialize(attributes = {})
    super
    @students = []
    @attendances = {}
    @attended_count = 0
    @absent_count = 0
    @unrecorded_count = 0
  end

  def search
    return false unless valid?

    # 1. 学生取得
    student_scope = User.student.order(:student_id)
    student_scope = student_scope.where(enrollment_year: enrollment_year) if enrollment_year.present?
    @students = student_scope.to_a

    # 2. 出席データ取得
    if period_number != 0
      attendances_list = Attendance.where(period_id: @period.id, date: @date).to_a
      @attendances = attendances_list.index_by(&:user_id)

      # 3. 集計
      @attended_count = attendances_list.count { |a| a.status == 'attended' }
      @absent_count = attendances_list.count { |a| a.status == 'absent' }
      @unrecorded_count = @students.count - attendances_list.count
    else
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

    weekday = @date.cwday
    @period = Period.find_by(weekday: weekday, period_number: period_number)
      
    unless @period && period_number != 0
      errors.add(:base, "指定された曜日・コマの授業が見つかりませんでした。")
    end
  end
end