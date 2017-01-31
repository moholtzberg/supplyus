class ShipmentMailer < ApplicationMailer
  
  def shipment_confirmation(shipment_id, options = {})
    
    @shipment = Shipment.find_by(:id => shipment_id)
    
    defaults = {
      :from => "24\/7 Office Supply <orders@247officesupply.com>"
      :to => @shipment.orders.first.email
    }
    
    options = defaults.merge(options)
    
    mail(
      :to => options[:to],
      :cc => options[:cc],
      :bcc => options[:bcc],
      :subject => "Shipment Notification #{@shipment.orders.first.number}", 
      :text => render_to_string("shipment_mailer/shipment_confirmation").to_str
    )
  end
  
end