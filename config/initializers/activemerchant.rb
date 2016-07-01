if Rails.env == "development"
  ActiveMerchant::Billing::BraintreeGateway.wiredump_device = File.open(Rails.root.join("log", "active_merchant.log"), "a+")
  ActiveMerchant::Billing::BraintreeGateway.wiredump_device.sync = true
  ActiveMerchant::Billing::Base.mode = :test
  
  merchant_id = "#{SECRET['ACTIVEMERCHANT']['DEV_MERCHANT_ID']}"
  public_key = "#{SECRET['ACTIVEMERCHANT']['DEV_PUBLIC_KEY']}"
  private_key = "#{SECRET['ACTIVEMERCHANT']['DEV_PRIVATE_KEY']}"
  
elsif Rails.env == "production"
  
  merchant_id = "#{SECRET['ACTIVEMERCHANT']['PROD_MERCHANT_ID']}"
  public_key = "#{SECRET['ACTIVEMERCHANT']['PROD_PUBLIC_KEY']}"
  private_key = "#{SECRET['ACTIVEMERCHANT']['PROD_PRIVATE_KEY']}"
  
end

GATEWAY = ActiveMerchant::Billing::BraintreeGateway.new({
  :merchant_id => merchant_id,
  :public_key  => public_key,
  :private_key => private_key
})