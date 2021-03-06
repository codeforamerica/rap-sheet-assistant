require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RapSheetAssistant
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.file_path_prefix = 'uploads'

    if ENV['SENTRY_DSN']
      Raven.configure do |config|
        config.dsn = ENV['SENTRY_DSN']
      end
    end

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
  end
end
