module Api
  module V1
    class TasksController < ActionController::API
      before_action :set_task, only: [ :show, :update, :destroy ]

      # GET /api/v1/tasks
      def index
        @tasks = Task.all
        render json: {
          status: "success",
          count: @tasks.count,
          data: @tasks
        }, status: :ok
      end

      # GET /api/v1/tasks/:id
      def show
        render json: { status: "success", data: @task }, status: :ok
      end

      # POST /api/v1/tasks
      def create
        @task = Task.new(task_params)
        if @task.save
          render json: { status: "created", data: @task }, status: :created
        else
          render json: { status: "error", errors: @task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/tasks/:id
      def update
        if @task.update(task_params)
          render json: { status: "success", data: @task }, status: :ok
        else
          render json: { status: "error", errors: @task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/tasks/:id
      def destroy
        @task.destroy
        render json: { status: "success", message: "Task deleted successfully" }, status: :ok
      end

      private

      def set_task
        @task = Task.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { status: "error", message: "Task not found" }, status: :not_found
      end

      def task_params
        params.require(:task).permit(:title, :description, :completed, :user_id)
      end
    end
  end
end
