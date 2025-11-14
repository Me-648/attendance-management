class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :attendances

  # バリデーション
  # 学生の場合のみ、student_id(学籍番号)とenrollment_year(入学年度)を必須にする
  validates :student_id, presence: true, uniqueness: true, if: :student?
  validates :enrollment_year, presence: true, if: :student?

  # emailは全員必須
  validates :email, presence: true, uniqueness: true

  # roleカラムにenumを定義
  # 0: student, 1: admin
  # デフォルトは student
  # Rails 7.1+ の構文。`student?` や `admin?` といったヘルパーメソッドが自動で定義されます。
  # `default: :student` により、新規作成時に自動で `student` が設定されます。
  enum :role, { student: 0, admin: 1 }, default: :student

  def is_admin?
    role == "admin"
  end
end
