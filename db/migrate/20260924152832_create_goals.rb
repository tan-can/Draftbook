class CreateGoals < ActiveRecord::Migration[8.1]
  def change
    create_table :goals do |t|
      t.string :title
      t.text :description
      t.string :category
      t.date :deadline
      t.integer :progress

      t.timestamps
    end
  end
end
