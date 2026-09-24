class TasksController < ApplicationController
  def index
    @tasks = Task.all.order(created_at: :desc)
  end

  def create
    user = (defined?(current_user) && current_user) || (defined?(Current) && Current.user) || User.first
    @task = user.tasks.build(task_params)

    if @task.save
      redirect_to tasks_path, notice: "Task added successfully! 🌸"
    else
      redirect_to tasks_path, alert: "Could not add task."
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    redirect_to tasks_path, notice: "Task deleted."
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :completed)
  end
end

class TasksController < ApplicationController
  def toggle
    @task = Task.find(params[:id])
    @task.update(completed: !@task.completed)
    redirect_to tasks_path, notice: "Task updated!"
  end

  # ... existing index, create, destroy actions
end
