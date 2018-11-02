class PurchaseOrderMailer < ApplicationMailer
  
  def purchase_order_confirmation(purchase_order_id, options = {})
    
    @purchase_order = PurchaseOrder.find_by(:id => purchase_order_id)
    
    defaults = {
      :from => "24\/7 Office Supply <orders@247officesupply.com>",
      :to => @purchase_order.vendor.email
    }
    options = defaults.merge(options)

    email = mail(
      :to => options[:to],
      :cc => options[:cc],
      :bcc => options[:bcc],
      :subject => "Purchase Order Notification #{@purchase_order.number}", 
      :html => render_to_string("purchase_order_mailer/purchase_order_confirmation"),
      :text => render_to_string("purchase_order_mailer/purchase_order_confirmation").to_str
    )
    @email_delivery = EmailDelivery.create({
      addressable_type: 'Vendor',
      addressable_id: @purchase_order.vendor_id,
      to_email: email[:to].to_s,
      body: email[:text].to_s,
      eventable_type: 'PurchaseOrder',
      eventable_id: @purchase_order.id
    })
    headers['X-Mailgun-Variables'] = @email_delivery.id
  end
  
end