class CreatePeriods < ActiveRecord::Migration[8.0]
  def change
    create_table :periods do |t|
      t.integer :period_number
      t.integer :weekday
      t.time :start_time

      t.timestamps
    end
  end
end
