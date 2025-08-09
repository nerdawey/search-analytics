Rails.application.config.after_initialize do
  begin
    redis_url = ENV['REDIS_URL']
    if redis_url
      $redis = Redis.new(url: redis_url)
      $redis.ping
      Rails.logger&.info "Redis connected successfully: #{redis_url}"
    else
      Rails.logger&.warn "REDIS_URL not set, Redis features will be disabled"
    end
  rescue => e
    Rails.logger&.error "Redis connection failed: #{e.message}"
  end
end
