Rails.application.config.after_initialize do
  redis_url = ENV['REDIS_URL']
  
  if redis_url
    Sidekiq.configure_server do |config|
      config.redis = { 
        url: redis_url,
        namespace: "search_analytics_#{Rails.env}"
      }
    end

    Sidekiq.configure_client do |config|
      config.redis = { 
        url: redis_url,
        namespace: "search_analytics_#{Rails.env}"
      }
    end
    
    Rails.logger&.info "Sidekiq configured with Redis: #{redis_url}"
  else
    Rails.logger&.warn "REDIS_URL not set, Sidekiq will use default configuration"
  end
end
