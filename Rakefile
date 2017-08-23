# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

Rake::Task['default'].clear

task default: :specs_thorough

task :specs_thorough do
  system 'bin/rspect'
end
