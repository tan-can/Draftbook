json.extract! habit, :id, :name, :streak, :best_streak, :last_done_on, :created_at, :updated_at
json.url habit_url(habit, format: :json)
