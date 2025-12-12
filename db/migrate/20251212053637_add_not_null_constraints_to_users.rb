class AddNotNullConstraintsToUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :student_id, false
    change_column_null :users, :enrollment_year, false
  end
end
