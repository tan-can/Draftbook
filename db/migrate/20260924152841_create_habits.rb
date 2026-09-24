class CreateHabits < ActiveRecord::Migration[8.1]
  def change
    create_table :habits do |t|
      t.string :name
      t.integer :streak
      t.integer :best_streak
      t.date :last_done_on

      t.timestamps
    end
  end
end
