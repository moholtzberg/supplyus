if Rails.env == "production"
  
  Sidekiq.configure_server do |config|
    config.redis = { url: "#{SECRET['REDIS_PROD_URL']}" }
  end
  
  Sidekiq.configure_client do |config|
    config.redis = { url: "#{SECRET['REDIS_PROD_URL']}" }
  end
  
elsif Rails.env == 'development'
  
  Sidekiq.configure_server do |config|
    config.redis = { url: "#{SECRET['REDIS_DEV_URL']}" }
  end
  
  Sidekiq.configure_client do |config|
    config.redis = { url: "#{SECRET['REDIS_DEV_URL']}" }
  end

elsif Rails.env == 'staging'

  Sidekiq.configure_server do |config|
    config.redis = { url: ENV["REDIS_URL"] }
  end
  
  Sidekiq.configure_client do |config|
    config.redis = { url: ENV["REDIS_URL"] }
  end
  
end