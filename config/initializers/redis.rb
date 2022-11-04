require 'redis'

url = ENV["SIDEKIQ_REDIS_URL"] || "redis://localhost:6379/1"
$redis = Redis.new(url: url)