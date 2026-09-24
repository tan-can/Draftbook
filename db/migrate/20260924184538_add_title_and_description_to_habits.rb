class AddTitleAndDescriptionToHabits < ActiveRecord::Migration[8.1]
  def change
    add_column :habits, :title, :string
    add_column :habits, :description, :string
  end
end
