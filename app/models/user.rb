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
  enum role: { student: 0, admin: 1 }, _default: :student

  # ヘルパーメソッド
  def is_admin?
    self.role == 1
  end

  def is_student?
    self.role == 0
  end

  private

  def set_default_role
    self.role ||= 0
  end
end
