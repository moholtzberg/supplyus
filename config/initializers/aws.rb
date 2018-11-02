Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(SECRET['AWS']['ACCESS_KEY_ID'], SECRET['AWS']['SECRET_ACCESS_KEY'])
})
Aws::VERSION =  Gem.loaded_specs["aws-sdk"].version