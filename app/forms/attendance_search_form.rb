class AttendanceSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :year, :integer
  attribute :month, :integer
  attribute :day, :integer
  attribute :period_number, :integer
  attribute :enrollment_year, :integer

  attr_reader :current_user

  validate :validate_current_user, :validate_date
  validates :year, :month, :day, presence: true

  with_options if: :is_admin? do
    validates :period_number, presence: true
    validates :enrollment_year, presence: true
    validate :validate_period
  end

  attr_reader :date, :period, :students, :attendances

  def initialize(attributes = {})
    @current_user = attributes.delete(:current_user) || attributes.delete("current_user")
    super
    @students = []
    @attendances = {}
  end

  # 出欠データを検索
  def search
    return false unless valid?

    if is_admin?
      @students = User.student.where(enrollment_year: enrollment_year).order(:student_id).to_a

      student_ids = @students.map(&:id)
      attendances = Attendance.where(period_id: @period.id, date: @date, user_id: student_ids).to_a
      @attendances = attendances.index_by(&:user_id)
    else
      @attendances = current_user.attendances.where(date: @date).index_by(&:period_id)
      @students = []
    end

    true
  end

  private

  def is_admin?
    current_user&.admin?
  end

  def validate_current_user
    return if current_user.present?

    errors.add(:base, "ユーザー情報が取得できませんでした。")
  end

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

    unless @period
      errors.add(:base, "指定された曜日・コマの授業が見つかりませんでした。")
    end
  end
end
