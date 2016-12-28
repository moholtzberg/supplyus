Recaptcha.configure do |config|
  config.site_key = "#{SECRET['RECAPTCHA']['SITE_KEY']}"
  config.secret_key = "#{SECRET['RECAPTCHA']['SECRET_KEY']}"
end