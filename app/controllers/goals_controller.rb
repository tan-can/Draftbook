class GoalsController < ApplicationController
  def index
    @goals = Goal.all.order(created_at: :desc)
  end

  def create
    user = (defined?(current_user) && current_user) || (defined?(Current) && Current.user) || User.first
    @goal = user.goals.build(goal_params)

    if @goal.save
      redirect_to goals_path, notice: "Goal added successfully! 🌸"
    else
      redirect_to goals_path, alert: "Could not add goal."
    end
  end

  def destroy
    @goal = Goal.find(params[:id])
    @goal.destroy
    redirect_to goals_path, notice: "Goal deleted."
  end

  private

  def goal_params
    params.require(:goal).permit(:title, :description, :completed)
  end
end

class GoalsController < ApplicationController
  def toggle
    @goal = Goal.find(params[:id])
    @goal.update(completed: !@goal.completed)
    redirect_to goals_path, notice: "Goal updated!"
  end

  # ... existing index, create, destroy actions
end
