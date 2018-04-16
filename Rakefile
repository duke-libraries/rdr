# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

require 'solr_wrapper/rake_task' unless Rails.env.production?

task :ci do
  Rails.env = 'test'
  with_server 'test' do
    Rake::Task['spec'].invoke
  end
end
