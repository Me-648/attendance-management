class AddUniqueIndexToAttendances < ActiveRecord::Migration[8.1]
  def change
    add_index :attendances, [ :user_id, :period_id, :date ], unique: true, name: "index_attendances_on_user_period_date"
  end
end
