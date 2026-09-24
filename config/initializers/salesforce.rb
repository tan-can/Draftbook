Restforce.configure do |config|
  config.api_version       = "58.0"
  config.client_id         = ENV.fetch("SALESFORCE_CLIENT_ID", nil)
  config.client_secret     = ENV.fetch("SALESFORCE_CLIENT_SECRET", nil)
  config.username          = ENV.fetch("SALESFORCE_USERNAME", nil)
  config.password          = ENV.fetch("SALESFORCE_PASSWORD", nil)
  config.security_token    = ENV.fetch("SALESFORCE_SECURITY_TOKEN", nil)
end
