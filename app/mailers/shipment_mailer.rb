class ShipmentMailer < ApplicationMailer
  default from: "orders@247officesupply.com"
  
  def shipment_confirmation(shipment_id)
    
    @shipment = Shipment.find_by(:id => shipment_id)
    
    mail(
         :to => @shipment.orders.first.account.user.email,
         :bcc => "sales@247officesupply.com",
         :subject => "24/7 Office Supply - Shipment Confirmation #{@shipment.orders.first.number}", 
         :text => render_to_string("shipment_mailer/shipment_confirmation").to_str
    )
  end
  
end