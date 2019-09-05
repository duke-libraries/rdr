source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'awesome_print'
gem 'bagit'
gem 'boxr'
gem 'coffee-rails', '~> 4.2'
gem 'curb', '~> 0.9.4'
gem 'ddr-antivirus'
gem 'devise', '>= 4.6.0'
gem 'devise-guests', '~> 0.6'
gem 'ezid-client'
gem 'hydra-role-management'
gem 'hyrax', '2.5.1'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'nokogiri', '>= 1.10.4'
gem 'mini_magick', '>= 4.9.4'
gem 'omniauth-shibboleth'
gem 'pg'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.4'
gem 'redis', '~> 3.0'
gem 'resque'
gem 'resque-pool', '~> 0.7.0'
gem 'resque-web', require: 'resque_web'
gem 'rsolr', '>= 1.0'
gem 'sass-rails', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'uglifier', '>= 1.3.0'

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
end
