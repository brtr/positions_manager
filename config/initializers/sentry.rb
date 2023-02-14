Raven.configure do |config|
  config.dsn                  = ENV["SENTRY_DSN"]
  config.environments         = %w[ production stage ]
  config.sanitize_fields      = Rails.application.config.filter_parameters.map(&:to_s)
  config.excluded_exceptions += ['Seahorse::Client::NetworkingError']
end
