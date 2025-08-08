# Configure Active Job queue adapter
Rails.application.config.after_initialize do
  if Rails.env.production?
    if ENV['REDIS_URL'].present?
      Rails.application.config.active_job.queue_adapter = :sidekiq
      Rails.logger&.info "Active Job configured with Sidekiq"
    else
      Rails.application.config.active_job.queue_adapter = :async
      Rails.logger&.warn "Active Job configured with async adapter (Redis not available)"
    end
  end
end
