web: ./bin/start-simple
worker: bundle exec sidekiq -C config/sidekiq.yml || echo "Sidekiq worker not started (Redis may not be available)"
