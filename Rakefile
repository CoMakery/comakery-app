# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'colorize'

require File.expand_path('../config/application', __FILE__)
Rails.application.load_tasks

Rake::Task['default'].clear

task default: :specs_thorough

task :specs_thorough do
  system 'bin/rspect'
end

desc 'Run all specs with SimpleCov'
task :coverage do
  run 'rm -rf ./coverage/'

  SPECS = Dir.chdir('spec') { Dir['**/*_spec.rb'] - Dir['features/**/*_spec.rb'] }.sort

  spec_successes = SPECS.map do |group|
    ENV['SIMPLECOV'] = 'true'
    ENV['SIMPLECOV_GROUP'] = group
    run "bundle exec bin/rspec --format documentation spec/#{group}"
  end

  specs_successful = spec_successes.all?
  if specs_successful
    info 'All specs ran successfully!'
  else
    err 'SOME SPECS FAILED, SEE ERRORS ABOVE'
  end

  merge_successful = run 'bundle exec bin/merge-simplecov'
  if merge_successful
    info 'Final coverage report run successful!'
  else
    err 'Final coverage report failed :('
  end

  exit 1 unless specs_successful && merge_successful
end

def run(cmd)
  puts
  puts "====> #{cmd}".cyan
  puts
  system cmd
end

def info(msg)
  puts
  puts msg.yellow
  puts
end

def err(msg)
  puts
  puts msg.red
  puts
end
