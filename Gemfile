source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.6'

gem 'bootsnap', require: false
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'rails', '~> 7.1.0'

gem 'redis', '~> 4.5.0'
gem 'sidekiq', '~> 6.5.12'

gem 'jbuilder'
gem 'sprockets-rails'
gem 'turbo-rails'

group :development, :test do
  gem 'capybara', '~> 3.39'
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.2'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rspec-rails', '~> 6.0'
  gem 'selenium-webdriver', '~> 4.10'
  gem 'shoulda-matchers', '~> 5.3'
  gem 'timecop', '~> 0.9'
  gem 'webdrivers', '~> 5.3'
end

group :development do
  gem 'annotate', '~> 3.2'
  gem 'brakeman', '~> 6.1'
  gem 'error_highlight', platforms: [:ruby]
  gem 'rubocop', '~> 1.50', require: false
  gem 'rubocop-rails', '~> 2.33', require: false
  gem 'rubocop-rspec', '~> 2.20', require: false
  gem 'web-console'
end

group :test do
  gem 'rspec-benchmark', '~> 0.6'
  gem 'vcr', '~> 6.1'
  gem 'webmock', '~> 3.18'
end

group :production do
  gem 'rack-attack', '~> 6.6'
end
