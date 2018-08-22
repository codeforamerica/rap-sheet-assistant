# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

begin
  RSpec::Core::RakeTask.new(:ocr) do |t|
    t.rspec_opts = '--tag ocr_integration'
  end
rescue NameError
  # rspec is not available
end

begin
  require 'bundler/audit/task'
  Bundler::Audit::Task.new

  task default: 'bundle:audit'
rescue NameError, LoadError
  # bundler-audit is not available
end

task :upload_test_images, [:pdf] do |t, args|
  pdf = args[:pdf]
  system "convert -verbose -density 300 -trim #{pdf}.pdf -quality 100 page.jpg"

  connection = Fog::Storage.new(
    provider: 'AWS',
    aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['AWS_SECRET_KEY']
  )

  directory = connection.directories.new(key: 'rap-sheet-test-data')


  Dir.glob('page-*.jpg').length.times do |i|
    page_filename = "page-#{i}.jpg"
    File.open(page_filename) { |image|
      directory.files.create(key: "#{pdf}/page_#{i + 1}.jpg", body: image, public: false)
    }
    File.delete(page_filename)
  end
end
