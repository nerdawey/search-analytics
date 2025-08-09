class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token

  def check
    render json: {
      status: 'ok',
      timestamp: Time.current,
      environment: Rails.env
    }
  end

  def simple
    render plain: 'OK', status: :ok
  end

  def detailed
    health_data = HealthCheckService.new.call
    render json: {
      status: 'ok',
      timestamp: Time.current,
      environment: Rails.env,
      database: health_data[:database],
      redis: health_data[:redis]
    }
  end
end
