require File.expand_path('../boot', __FILE__)

require 'csv'
require 'aws-sdk-v1'
require 'rails/all'
# require 'pdfkit'
require 'wicked_pdf'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

secret_file = Rails.env == "development" ? "../shared/app_secrets.yml"  : "../../shared/app_secrets.yml"
puts "++++++++++++++#{secret_file}"
SECRET = File.exists?(secret_file) ? YAML.load_file(secret_file) : {}
puts "++++++++++++++#{SECRET.inspect}"

# AWS.config({
#     :access_key_id => "#{SECRET['AWS']['ACCESS_KEY_ID']}",
#     :secret_access_key => "#{SECRET['AWS']['SECRET_ACCESS_KEY']}",
# })

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
    # config.middleware.use "PDFKit::Middleware", :print_media_type => true
    config.middleware.use WickedPdf::Middleware, :print_media_type => true
  end
end