class HealthController < ApplicationController
  # Skip CSRF protection for health checks
  skip_before_action :verify_authenticity_token
  
  def check
    # Simple health check that responds quickly
    render json: {
      status: 'ok',
      timestamp: Time.current,
      environment: Rails.env
    }
  end

  def simple
    # Ultra-simple health check for Railway
    render plain: 'OK', status: 200
  end

  def detailed
    # Detailed health check with database and Redis status
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
    if defined?(Redis) && ENV['REDIS_URL'].present?
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
