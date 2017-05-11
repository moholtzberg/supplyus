if Rails.env == "production"
  
  Sidekiq.configure_server do |config|
    config.redis = { url: "#{SECRET['REDIS_PROD_URL']}" }
  end
  
  Sidekiq.configure_client do |config|
    config.redis = { url: "#{SECRET['REDIS_PROD_URL']}" }
  end
  
else
  
  Sidekiq.configure_server do |config|
    config.redis = { url: "#{SECRET['REDIS_DEV_URL']}" }
  end
  
  Sidekiq.configure_client do |config|
    config.redis = { url: "#{SECRET['REDIS_DEV_URL']}" }
  end
  
end
