class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  has_many :attendances, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :student_id, presence: true, uniqueness: true
  validates :enrollment_year, presence: true

  # 0: student, 1: admin
  enum :role, { student: 0, admin: 1 }, default: :student
end
