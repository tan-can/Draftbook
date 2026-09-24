require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Draftbook
  class Application < Rails::Application
    # ... keep existing configuration
  end
end
