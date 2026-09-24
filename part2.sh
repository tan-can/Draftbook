#!/usr/bin/env bash
# Whimsy MVP: Rails 8 + MySQL + Tailwind. Auth, Dashboard, Tasks, Goals, Habits.
set -e

# Authentication (Rails 8 built-in: sessions, password hashing, reset)
bin/rails generate authentication

# Resources
bin/rails g scaffold Task title description:text due_date:date priority status category
bin/rails g scaffold Goal title description:text category deadline:date progress:integer
bin/rails g scaffold Habit name streak:integer best_streak:integer last_done_on:date
for m in tasks goals habits; do bin/rails g migration AddUserTo$(echo $m | sed 's/./\U&/') user:references; done

# Scope every controller to the logged-in user
for pair in "Task:tasks" "Goal:goals" "Habit:habits"; do
  C=${pair%%:*}; P=${pair##*:}
  sed -i "s/$C\.all/Current.user.$P/; s/$C\.find/Current.user.$P.find/; s/$C\.new/Current.user.$P.new/" app/controllers/$P\_controller.rb
done
sed -i 's/form.text_field :priority/form.select :priority, %w[low medium high]/; s/form.text_field :status/form.select :status, %w[pending done]/' app/views/tasks/_form.html.erb

# Models
cat > app/models/task.rb <<'EOF'
class Task < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  scope :open, -> { where.not(status: "done") }
end
EOF
cat > app/models/goal.rb <<'EOF'
class Goal < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  validates :progress, numericality: { in: 0..100 }, allow_nil: true
end
EOF
cat > app/models/habit.rb <<'EOF'
class Habit < ApplicationRecord
  belongs_to :user
  validates :name, presence: true
  def done_today? = last_done_on == Date.current
  def check_in!
    return if done_today?
    self.streak = last_done_on == Date.current - 1 ? streak.to_i + 1 : 1
    self.best_streak = [best_streak.to_i, streak].max
    self.last_done_on = Date.current
    save!
  end
end
EOF
cat >> app/models/user.rb <<'EOF'
EOF
sed -i 's/^class User < ApplicationRecord/class User < ApplicationRecord\n  has_many :tasks, dependent: :destroy\n  has_many :goals, dependent: :destroy\n  has_many :habits, dependent: :destroy/' app/models/user.rb

# Habit "done today" action
sed -i 's/^  def set_habit/  def complete\n    Current.user.habits.find(params[:id]).check_in!\n    redirect_back fallback_location: root_path\n  end\n\n  private\n\n  def set_habit/' app/controllers/habits_controller.rb

# Sign up
mkdir -p app/views/registrations app/views/dashboard app/views/shared
cat > app/controllers/registrations_controller.rb <<'EOF'
class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  def new = @user = User.new
  def create
    @user = User.new(params.expect(user: [:email_address, :password, :password_confirmation]))
    if @user.save
      start_new_session_for @user
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end
EOF
cat > app/views/registrations/new.html.erb <<'EOF'
<div class="max-w-sm mx-auto mt-16 p-6">
  <h1 class="text-3xl font-bold text-center">✨ WHIMSY</h1>
  <p class="text-center text-gray-500 mb-6">Your life. Your next move.</p>
  <%= form_with model: @user, url: registration_path, class: "space-y-3" do |f| %>
    <% @user.errors.full_messages.each do |m| %><p class="text-red-600 text-sm"><%= m %></p><% end %>
    <%= f.email_field :email_address, placeholder: "Email", required: true, class: "w-full border rounded p-2" %>
    <%= f.password_field :password, placeholder: "Password", required: true, class: "w-full border rounded p-2" %>
    <%= f.password_field :password_confirmation, placeholder: "Confirm password", required: true, class: "w-full border rounded p-2" %>
    <%= f.submit "Sign up", class: "w-full bg-indigo-600 text-white rounded p-2 cursor-pointer" %>
  <% end %>
  <p class="text-center mt-4 text-sm"><%= link_to "Already have an account? Log in", new_session_path, class: "text-indigo-600" %></p>
</div>
EOF

# Dashboard
cat > app/controllers/dashboard_controller.rb <<'EOF'
class DashboardController < ApplicationController
  def index
    @tasks  = Current.user.tasks.open.order(:due_date).limit(8)
    @goals  = Current.user.goals.order(:deadline)
    @habits = Current.user.habits
    @done   = Current.user.tasks.where(status: "done").count
    @total  = Current.user.tasks.count
  end
end
EOF
cat > app/views/dashboard/index.html.erb <<'EOF'
<div class="max-w-4xl mx-auto p-6 space-y-8">
  <h1 class="text-2xl font-bold">Hello, <%= Current.user.email_address.split("@").first %> ✨</h1>
  <p class="text-gray-500">Tasks completed: <%= @done %> / <%= @total %>
    (<%= @total.zero? ? 0 : (@done * 100 / @total) %>%)</p>

  <section>
    <h2 class="font-semibold text-lg mb-2">Today</h2>
    <% @tasks.each do |t| %>
      <p>☐ <%= link_to t.title, t %> <span class="text-xs text-gray-500"><%= t.priority %> · <%= t.due_date %></span></p>
    <% end %>
    <%= link_to "+ New task", new_task_path, class: "text-indigo-600 text-sm" %>
  </section>

  <section>
    <h2 class="font-semibold text-lg mb-2">Goals</h2>
    <% @goals.each do |g| %>
      <div class="mb-2">
        <%= link_to g.title, g %> <span class="text-xs"><%= g.progress.to_i %>%</span>
        <div class="bg-gray-200 rounded h-2"><div class="bg-indigo-600 h-2 rounded" style="width: <%= g.progress.to_i %>%"></div></div>
      </div>
    <% end %>
    <%= link_to "+ New goal", new_goal_path, class: "text-indigo-600 text-sm" %>
  </section>

  <section>
    <h2 class="font-semibold text-lg mb-2">Habits</h2>
    <% @habits.each do |h| %>
      <div class="flex items-center gap-3">
        <span>🔥 <%= h.streak.to_i %> days</span> <%= link_to h.name, h %>
        <% if h.done_today? %>✅<% else %><%= button_to "Done today", complete_habit_path(h), method: :post, class: "text-sm bg-indigo-100 px-2 rounded" %><% end %>
      </div>
    <% end %>
    <%= link_to "+ New habit", new_habit_path, class: "text-indigo-600 text-sm" %>
  </section>
</div>
EOF

# Nav + routes
cat > app/views/shared/_nav.html.erb <<'EOF'
<nav class="flex gap-4 items-center p-4 border-b">
  <%= link_to "✨ Whimsy", root_path, class: "font-bold" %>
  <%= link_to "Tasks", tasks_path %> <%= link_to "Goals", goals_path %> <%= link_to "Habits", habits_path %>
  <span class="ml-auto"><%= button_to "Logout", session_path, method: :delete %></span>
</nav>
EOF
sed -i 's|<body>|<body><%= render "shared/nav" if authenticated? %>|' app/views/layouts/application.html.erb
sed -i 's|^end$|  root "dashboard#index"\n  resource :registration, only: %i[new create]\n  resources :habits do\n    member { post :complete }\n  end\nend|' config/routes.rb
sed -i '0,/resources :habits/{/^  resources :habits$/d}' config/routes.rb

echo "Now edit config/database.yml (MySQL password), then run: bin/rails db:create db:migrate && bin/dev"
