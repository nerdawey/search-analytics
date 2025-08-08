# Configure Sidekiq for production
if Rails.env.production?
  redis_url = ENV['REDIS_URL']
  
  if redis_url
    Sidekiq.configure_server do |config|
      config.redis = { url: redis_url }
    end

    Sidekiq.configure_client do |config|
      config.redis = { url: redis_url }
    end
    
    Rails.logger.info "Sidekiq configured with Redis"
  else
    Rails.logger.warn "REDIS_URL not set, Sidekiq will not work properly"
  end
end
