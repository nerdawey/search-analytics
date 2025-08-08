class HealthController < ApplicationController
  def check
    render json: {
      status: 'ok',
      timestamp: Time.current,
      environment: Rails.env,
      database: database_status,
      redis: redis_status
    }
  end

  private

  def database_status
    ActiveRecord::Base.connection.execute('SELECT 1')
    'connected'
  rescue => e
    'error: ' + e.message
  end

  def redis_status
    if defined?(Redis)
      redis = Redis.new(url: ENV['REDIS_URL'])
      redis.ping
      'connected'
    else
      'not configured'
    end
  rescue => e
    'error: ' + e.message
  end
end
