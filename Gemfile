source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.0'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'carrierwave', '~> 1.0'
gem 'fog-aws'
gem 'mini_magick'
gem 'rtesseract'
gem 'google-cloud-vision', '>= 0.28.0'
gem 'jquery-rails'
gem 'sprockets-rails', '> 2.3.2'
gem 'bootstrap', '~> 4.1.2'
gem 'bootsnap'
gem 'pdf-forms'
gem 'cliver'
gem 'sentry-raven'
gem 'cfa-styleguide', git: 'https://github.com/codeforamerica/cfa-styleguide-gem'
gem 'rap_sheet_parser', :git => 'https://github.com/codeforamerica/rap_sheet_parser'
# gem 'rap_sheet_parser', path: '../rap_sheet_parser'

group :development, :test do
  gem 'factory_bot_rails'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'rspec-rails', '~> 3.7'
  gem 'rspec_junit_formatter'
  gem 'dotenv-rails'
  gem 'fog-local'
  gem 'spring-commands-rspec'
  gem 'launchy'
  gem 'bundler-audit'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
