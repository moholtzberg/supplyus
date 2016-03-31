class OrderMailer < ApplicationMailer
  
  default from: "orders@247officesupply.com"
  
  def order_confirmation(order_id)
    
    @order = Order.find_by(:id => order_id)
    
    mail(
         :to => @order.account.user.email,
         :bcc => "sales@247officesupply.com",
         :subject => "24/7 Office Supply - Order Confirmation #{@order.number}", 
         :text => render_to_string("order_mailer/order_confirmation").to_str
    )
  end
  
  def invoice_notification(order_id)
    
    @order = Order.find_by(:id => order_id)
    
    mail(
         :to => @order.account.user.email,
         :bcc => "sales@247officesupply.com",
         :subject => "24/7 Office Supply - Invoice Notification #{@order.number}", 
         :text => render_to_string("order_mailer/order_confirmation").to_str
    )
  end
  
  invoice_notification
  
end