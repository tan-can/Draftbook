class DashboardController < ApplicationController
  def index
    @tasks = Current.user.tasks if Current.user.respond_to?(:tasks)
    @goals = Current.user.goals if Current.user.respond_to?(:goals)
    @habits = Current.user.habits if Current.user.respond_to?(:habits)
  end
end
