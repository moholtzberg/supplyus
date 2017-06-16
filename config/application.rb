require File.expand_path('../boot', __FILE__)

require 'csv'
require 'aws-sdk-v1'
require 'rails/all'
require 'wicked_pdf'

Bundler.require(*Rails.groups)

SHARED_DIR = Rails.env == "development" ? File.expand_path("../shared", "#{Rails.root}")  : File.expand_path("../shared", "#{Rails.root}")
secret_file = secret_file = "#{SHARED_DIR}/app_secrets.yml"
SECRET = File.exists?(secret_file) ? YAML.load_file(secret_file) : {}
puts "++++++++++++++ #{SECRET.inspect}\n"

module Recurring
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

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
  end
end