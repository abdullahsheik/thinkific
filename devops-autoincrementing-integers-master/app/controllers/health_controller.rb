class HealthController < ApplicationController
  def show
    # Check database connectivity
    db_status = ActiveRecord::Base.connection.active? ? 'ok' : 'error'
    
    # Check Redis connectivity (if available)
    redis_status = begin
      Redis.new(url: ENV['REDIS_URL']).ping == 'PONG' ? 'ok' : 'error'
    rescue => e
      'error'
    end
    
    render json: {
      status: 'healthy',
      timestamp: Time.current.iso8601,
      services: {
        database: db_status,
        redis: redis_status
      }
    }
  end
end
