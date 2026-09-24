module Admin
  class ApplicationController < ::ApplicationController
    before_action :ensure_admin!

    private

    def ensure_admin!
      unless Current.user&.admin?
        redirect_to root_path, alert: "Access denied! Admin privileges required."
      end
    end
  end
end
