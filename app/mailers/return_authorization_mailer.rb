class ReturnAuthorizationMailer < ApplicationMailer
  
  def confirm(return_authorization_id, options = {})
    
    @return_authorization = ReturnAuthorization.find_by(:id => return_authorization_id)
    
    defaults = {
      :from => "24\/7 Office Supply <orders@247officesupply.com>",
      :to => @return_authorization.customer.email
    }
    
    options = defaults.merge(options)
    
    email = mail(
      :to => options[:to],
      :cc => options[:cc],
      :bcc => options[:bcc],
      :subject => "Return authorization for order #{@return_authorization.order_number} confirmed", 
      :text => render_to_string("return_authorization_mailer/confirm").to_str
    )
    @email_delivery = EmailDelivery.create({
      addressable_type: 'Account',
      addressable_id: @return_authorization.customer_id,
      to_email: @return_authorization.customer.email,
      body: email[:text].to_s,
      eventable_type: 'ReturnAuthorization',
      eventable_id: @return_authorization.id
    })
    headers['X-Mailgun-Variables'] = @email_delivery.id
  end
  
  def cancel(return_authorization_id, options = {})
    
    @return_authorization = ReturnAuthorization.find_by(:id => return_authorization_id)
    
    defaults = {
      :from => "24\/7 Office Supply <orders@247officesupply.com>",
      :to => @return_authorization.customer.email
    }
    
    options = defaults.merge(options)
    
    email = mail(
      :to => options[:to],
      :cc => options[:cc],
      :bcc => options[:bcc],
      :subject => "Return authorization for order #{@return_authorization.order_number} canceled", 
      :text => render_to_string("return_authorization_mailer/cancel").to_str
    )
    @email_delivery = EmailDelivery.create({
      addressable_type: 'Account',
      addressable_id: @return_authorization.customer_id,
      to_email: @return_authorization.customer.email,
      body: email[:text].to_s,
      eventable_type: 'ReturnAuthorization',
      eventable_id: @return_authorization.id
    })
    headers['X-Mailgun-Variables'] = @email_delivery.id
  end
  
end