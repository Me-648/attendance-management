class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.integer :role, null: false
      t.string :student_id, null: true
      t.integer :enrollment_year, null: true

      t.timestamps
    end

    add_index :users, :student_id, unique: true, where: 'student_id IS NOT NULL'
  end
end
