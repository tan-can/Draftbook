json.extract! goal, :id, :title, :description, :category, :deadline, :progress, :created_at, :updated_at
json.url goal_url(goal, format: :json)
