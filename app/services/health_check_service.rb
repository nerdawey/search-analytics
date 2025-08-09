class HealthCheckService < BaseService
  def call
    {
      database: check_database,
      redis: check_redis
    }
  end

  private

  def check_database
    Article.count
    'connected'
  rescue StandardError => e
    "error: #{e.message}"
  end

  def check_redis
    if defined?(Redis) && ENV['REDIS_URL'].present?
      redis = Redis.new(url: ENV.fetch('REDIS_URL', nil))
      redis.ping
      'connected'
    else
      'not configured'
    end
  rescue StandardError => e
    "error: #{e.message}"
  end
end
