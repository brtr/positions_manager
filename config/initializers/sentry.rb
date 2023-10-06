Sentry.init do |config|
  config.dsn                   = ENV["SENTRY_DSN"]
  config.enabled_environments  = %w[ production stage ]
  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, hint|
    filter.filter(event.to_hash)
  end
end
