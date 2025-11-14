class Period < ApplicationRecord
  has_many :attendances, dependent: :destroy
  has_many :users, through: :attendances

  WEEKDAYS_JA = {
    1 => "月",
    2 => "火",
    3 => "水",
    4 => "木",
    5 => "金",
    6 => "土",
    7 => "日"
  }.freeze

  def weekday_ja
    WEEKDAYS_JA[weekday]
  end
end
