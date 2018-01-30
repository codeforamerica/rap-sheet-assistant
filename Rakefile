# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

RSpec::Core::RakeTask.new(:ocr) do |t|
  t.rspec_opts = '--tag ocr_integration'
end
