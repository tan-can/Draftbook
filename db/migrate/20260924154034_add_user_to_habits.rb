class AddUserToHabits < ActiveRecord::Migration[8.1]
  def change
    add_reference :habits, :user, null: false, foreign_key: true
  end
end
