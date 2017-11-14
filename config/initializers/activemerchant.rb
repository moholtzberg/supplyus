if Rails.env == "development" || Rails.env == "staging"
  ActiveMerchant::Billing::BraintreeGateway.wiredump_device = File.open(Rails.root.join("log", "active_merchant.log"), "a+")
  ActiveMerchant::Billing::BraintreeGateway.wiredump_device.sync = true
  ActiveMerchant::Billing::Base.mode = :test
  
  mode = :sandbox
  merchant_id = "#{SECRET['ACTIVEMERCHANT']['DEV_MERCHANT_ID']}"
  public_key = "#{SECRET['ACTIVEMERCHANT']['DEV_PUBLIC_KEY']}"
  private_key = "#{SECRET['ACTIVEMERCHANT']['DEV_PRIVATE_KEY']}"
  
elsif Rails.env == "production"
  
  mode = :production
  merchant_id = "#{SECRET['ACTIVEMERCHANT']['PROD_MERCHANT_ID']}"
  public_key = "#{SECRET['ACTIVEMERCHANT']['PROD_PUBLIC_KEY']}"
  private_key = "#{SECRET['ACTIVEMERCHANT']['PROD_PRIVATE_KEY']}"
  
end
Braintree::Configuration.environment = mode
Braintree::Configuration.merchant_id = merchant_id
Braintree::Configuration.private_key = private_key
Braintree::Configuration.public_key = public_key

GATEWAY = ActiveMerchant::Billing::BraintreeGateway.new({
  :merchant_id => merchant_id,
  :public_key  => public_key,
  :private_key => private_key
})

