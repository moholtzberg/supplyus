class OrderMailer < ApplicationMailer
  default from: "orders@247officesupply.com"
  
  def order_confirmation(order_id)
    
    @order = Order.find_by(:id => order_id)
    
    mail(
         :to => @order.account.user.email,
         :subject => "24/7 Office Supply - Order Confirmation #{@order.number}", 
         :text => render_to_string("order_mailer/order_confirmation").to_str
    )
    mail(
         :to => "admin@247officesupply.com",
         :subject => "[COPY] 24/7 Office Supply - Order Confirmation #{@order.number}", 
         :text => render_to_string("order_mailer/order_confirmation").to_str
    )
  end
  
end