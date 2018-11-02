require File.expand_path('../boot', __FILE__)

require 'csv'
require 'aws-sdk'
require 'rails/all'
require 'wicked_pdf'
# require 'mechanize'

Bundler.require(*Rails.groups)
APP_NAME = Rails.env == "development" ? File.expand_path(".", "#{Rails.root}").split("/").last : File.expand_path(".", "#{Rails.root}").split("/").last
SHARED_DIR = Rails.env == "development" ? File.expand_path("../shared", "#{Rails.root}")  : File.expand_path("../shared", "#{Rails.root}")
secret_file = "#{APP_NAME}_secrets.yml"
# for heroku deploy
secret_file = "shared/#{APP_NAME}_secrets.yml" if !File.exists?(secret_file)
puts secret_file
SECRET = File.exists?(secret_file) ? YAML.load_file(secret_file) : {}
puts "++++++++++++++ #{SECRET.inspect}\n"

module Recurring
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.middleware.use Rack::Attack
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Eastern Time (US & Canada)'
    # config.active_record.default_timezone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    REVISION = `git log --pretty=format:'%h' -n 1`
    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.eager_load_paths << Rails.root.join('lib')
    
    config.lograge.enabled = false
    config.lograge.custom_options = lambda do |event| 
      {
        params: event.payload[:params],
        exception: event.payload[:exception], # ["ExceptionClass", "the message"]
        exception_object: event.payload[:exception_object] # the exception instance
      }
    end
    
    config.lograge.custom_payload do |controller|
      {
        host: controller.request.host,
        user_id: controller.current_user.try(:id)
      }
    end
    
  end
end