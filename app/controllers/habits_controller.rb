class HabitsController < ApplicationController
  def index
    @habits = Habit.all.order(created_at: :desc)
  end

  def create
    # Logged-in user dhoondho (ya testing ke liye pehla user use karo)
    user = (defined?(current_user) && current_user) || (defined?(Current) && Current.user) || User.first

    @habit = user.habits.build(habit_params)

    if @habit.save
      redirect_to habits_path, notice: "Habit created successfully! 🌸"
    else
      redirect_to habits_path, alert: "Could not add habit."
    end
  end

  def destroy
    @habit = Habit.find(params[:id])
    @habit.destroy
    redirect_to habits_path, notice: "Habit deleted."
  end

  private

  def habit_params
    params.require(:habit).permit(:title, :description)
  end
end
