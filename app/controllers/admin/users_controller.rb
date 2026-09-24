module Admin
  class UsersController < Admin::ApplicationController
    def index
      @users = User.all.order(created_at: :desc)
    end

    def destroy
      @user = User.find(params[:id])
      @user.destroy
      redirect_to admin_users_path, notice: "User deleted successfully."
    end
  end
end
