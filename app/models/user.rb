class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :attendances

  # バリデーション
  # 学生の場合のみ、student_id(学籍番号)とenrollment_year(入学年度)を必須にするロジック
  validates :student_id, presence: true, uniqueness: true, if: :is_student?
  validates :enrollment_year, presence: true, if: :is_student?

  # emailは全員必須
  validates :email, presence: true, uniqueness: true

  # roleのデフォルト値(新規作成は学生なので0)を設定
  after_initialize :set_default_role, if: :new_record?


  # ヘルパーメソッド
  def is_student?
    self.role == 0
  end

  private

  def set_default_role
    self.role ||= 0
  end
end
