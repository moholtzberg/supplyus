class SubscriptionMailer < ApplicationMailer
  
  def update_cc(subscription_id, options = {})
    
    @subscription = Subscription.find_by(:id => subscription_id)
    
    defaults = {
      :from => "24\/7 Office Supply <orders@247officesupply.com>",
      :to => @subscription.account.email
    }
    options = defaults.merge(options)
    
    email = mail(
         :to => options[:to],
         :cc => options[:cc],
         :bcc => options[:bcc],
         :subject => "Update credit card data for #{@subscription.item.name} subscription", 
         :text => render_to_string("order_mailer/order_confirmation").to_str
    )
    @email_delivery = EmailDelivery.create({
      addressable_type: 'Account',
      addressable_id: @subscription.account_id,
      to_email: @subscription.account.email,
      body: email[:text].to_s,
      eventable_type: 'Subscription',
      eventable_id: @subscription.id
    })
    headers['X-Mailgun-Variables'] = @email_delivery.id
  end
  
end