module Admin
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

      Rails.logger.info "=" * 60
      Rails.logger.info "AttendanceSearchForm#search START"
      Rails.logger.info "Params: year=#{year}, month=#{month}, day=#{day}, period=#{period_number}, enrollment_year=#{enrollment_year}"

      # 1. 学生取得
      student_scope = User.student.order(:student_id)
      student_scope = student_scope.where(enrollment_year: enrollment_year) if enrollment_year.present?
      @students = student_scope.to_a
      
      Rails.logger.info "Students loaded: #{@students.count}"

      # 2. 出席データ取得
      attendances_list = Attendance.where(period_id: @period.id, date: @date).to_a
      @attendances = attendances_list.index_by(&:user_id)
      
      Rails.logger.info "Attendances loaded: #{attendances_list.count}"

      # 3. 集計
      @attended_count = attendances_list.count { |a| a.status == 'attended' }
      @absent_count = attendances_list.count { |a| a.status == 'absent' }
      @unrecorded_count = @students.count - attendances_list.count  # 未記録数を計算
      
      Rails.logger.info "Result: Attended=#{@attended_count}, Absent=#{@absent_count}, Unrecorded=#{@unrecorded_count}"
      Rails.logger.info "AttendanceSearchForm#search END"
      Rails.logger.info "=" * 60

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
      
      unless @period
        errors.add(:base, "指定された曜日・コマの授業が見つかりませんでした。")
      end
    end
  end
end