source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.4'
gem 'sqlite3'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'figaro'
gem 'redis', '~> 3.0'
gem 'rsolr', '>= 1.0'
gem 'jquery-rails'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'omniauth-shibboleth'
gem 'curb', '~> 0.9.4'

gem 'hyrax', '2.1.0'

gem 'resque'
gem 'resque-pool'
gem 'resque-web', require: 'resque_web'

gem 'bagit'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Use postgresql for all environments, not just production
gem 'pg'

# for group management
gem 'hydra-role-management'

# for ARK's
gem 'ezid-client'

# for Box API
gem 'boxr'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'solr_wrapper', '>= 0.3'
  gem 'fcrepo_wrapper'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rails-controller-testing'
  gem 'factory_bot_rails', '~> 4.8'
  gem 'webmock'
end

group :production do
  gem 'therubyracer', platforms: :ruby
  gem 'passenger'
end
