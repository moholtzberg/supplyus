class ShipmentMailer < ApplicationMailer
  
  def shipment_confirmation(shipment_id, options = {})
    
    @shipment = Shipment.find_by(:id => shipment_id)
    
    defaults = {
      :from => "24\/7 Office Supply <orders@247officesupply.com>",
      :to => @shipment.orders.first.email
    }
    
    options = defaults.merge(options)
    
    email = mail(
      :to => options[:to],
      :cc => options[:cc],
      :bcc => options[:bcc],
      :subject => "Shipment Notification #{@shipment.orders.first.number}", 
      :text => render_to_string("shipment_mailer/shipment_confirmation").to_str
    )
    @email_delivery = EmailDelivery.create({
      addressable_type: 'User',
      addressable_id: @shipment.orders.first.user_id,
      to_email: @shipment.orders.first.email,
      body: email[:text].to_s,
      eventable_type: 'Shipment',
      eventable_id: @shipment.id
    })
    headers['X-Mailgun-Variables'] = @email_delivery.id
  end
  
end