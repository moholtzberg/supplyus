class SubscriptionMailer < ApplicationMailer
  
  def update_cc(subscription_id, options = {})
    
    @subscription = Subscription.find_by(:id => subscription_id)
    
    defaults = {
      :from => "24\/7 Office Supply <orders@247officesupply.com>",
      :to => @subscription.account.email
    }
    options = defaults.merge(options)
    
    mail(
         :to => options[:to],
         :cc => options[:cc],
         :bcc => options[:bcc],
         :subject => "Update credit card data for #{@subscription.item.name} subscription", 
         :text => render_to_string("order_mailer/order_confirmation").to_str
    )
  end
  
end