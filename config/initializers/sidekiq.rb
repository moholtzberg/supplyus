Sidekiq.configure_server do |config|
  config.redis = { url: "#{SECRET['REDIS_URL']}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "#{SECRET['REDIS_URL']}" }
end
