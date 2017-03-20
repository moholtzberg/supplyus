if Rails.env == "production"
  QB_KEY = "#{SECRET['QUICKBOOKS']['PROD_KEY']}"
  QB_SECRET = "#{SECRET['QUICKBOOKS']['PROD_SECRET']}"
  QboApi.production = true
  QboApi.log = true
else
  QB_KEY = "#{SECRET['QUICKBOOKS']['DEV_KEY']}"
  QB_SECRET = "#{SECRET['QUICKBOOKS']['DEV_SECRET']}"
  QboApi.log = true
end

# $qb_oauth_consumer = OAuth::Consumer.new(QB_KEY, QB_SECRET, {
#     :site                 => "https://oauth.intuit.com",
#     :request_token_path   => "/oauth/v1/get_request_token",
#     :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
#     :access_token_path    => "/oauth/v1/get_access_token"
# })

# if Setting.find_by(:key => "store_name") == nil
#   STORE_NAME = Setting.create(:key => "store_name", :value => "My Awsome Shop").value
#   STORE_PHONE_NUMBER = Setting.create(:key => "store_name", :value => "My Awsome Shop").value
# else
#   STORE_NAME = Setting.find_by(:key => "store_name").value
# end
  