module Student
  class HomeFacade
    attr_reader :user, :year, :month

    def initialize(user, params = {})
      @user = user
      @year = (params[:year] || Date.current.year).to_i
      @month = (params[:month] || Date.current.month).to_i
    end

    # 本日の授業（時限順）
    def periods
      @periods ||= Period.where(weekday: Date.current.wday).order(:start_time)
    end

    # 本日の出席記録 { period_id => attendance }
    def today_attendances
      @today_attendances ||= user.attendances.where(date: Date.current).index_by(&:period_id)
    end

    # 統計情報
    def stats
      @stats ||= Attendance.stats_for_user(user.id)
    end

    # 月別一覧データ
    # { date => { period_number => attendance } }
    def monthly_attendances
      start_date = Date.new(@year, @month, 1) rescue Date.current.beginning_of_month
      end_date = start_date.end_of_month

      attendances = user.attendances.includes(:period)
                        .where(date: start_date..end_date)
                        .order(date: :desc)

      attendances.group_by(&:date).transform_values do |daily_atts|
        daily_atts.index_by { |att| att.period.period_number }
      end
    end

    # テーブルヘッダー用の時限番号リスト
    def period_headers
      @period_headers ||= Period.select(:period_number).distinct.pluck(:period_number).sort
    end
  end
end
