# Redis configuration for all environments
Rails.application.config.after_initialize do
  begin
    redis_url = ENV['REDIS_URL']
    if redis_url
      $redis = Redis.new(url: redis_url)
      # Test the connection
      $redis.ping
      Rails.logger&.info "Redis connected successfully: #{redis_url}"
    else
      Rails.logger&.warn "REDIS_URL not set, Redis features will be disabled"
    end
  rescue => e
    Rails.logger&.error "Redis connection failed: #{e.message}"
    # Don't crash the app if Redis is not available
  end
end
