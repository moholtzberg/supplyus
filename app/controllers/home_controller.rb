class HomeController < ApplicationController
  layout "admin"
  
  def show
    @account = Account.new
    @upcoming_charges = PaymentPlan.all.active
    @invoices = Invoice.all
  end
  
  def authenticate
    callback = oauth_callback_home_url
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
   at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
   session[:token] = at.token
   session[:secret] = at.secret
   session[:realm_id] = params['realmId']
   persist_values_to_db
   redirect_to home_url, notice: "Your QuickBooks account has been successfully linked."
  end
  
  def persist_values_to_db
    token = Setting.find_or_initialize_by(:key => "qb_token")
    token.value = session[:token]
    token.save
    secret = Setting.find_or_initialize_by(:key => "qb_secret")
    secret.value = session[:secret]
    secret.save
    realm = Setting.find_or_initialize_by(:key => "qb_realm")
    realm.value = session[:realm_id]
    realm.save
  end
  
end