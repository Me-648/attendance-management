class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  has_many :attendances, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  # 学生の場合のみ、student_id(学籍番号)とenrollment_year(入学年度)を必須にする
  validates :student_id, presence: true, uniqueness: true, if: :student?
  validates :enrollment_year, presence: true, if: :student?

  # 0: student, 1: admin
  enum :role, { student: 0, admin: 1 }, default: :student
end
