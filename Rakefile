# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

Rake::Task["default"].clear

task default: :specs_thorough

task :specs_thorough do
  run "testrpc -p 7777 >/dev/null &", continue_on_failure: true
  run "bin/rspect"
  run "cd ethereum && truffle test"
end
