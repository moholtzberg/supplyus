class OrderMailer < ApplicationMailer
  
  default from: "24\/7 Office Supply <orders@247officesupply.com>"
  
  def order_confirmation(order_id)
    
    @order = Order.find_by(:id => order_id)
    
    mail(
         :to => @order.email,
         :bcc => "sales@247officesupply.com",
         :subject => "Order Notification #{@order.number}", 
         :text => render_to_string("order_mailer/order_confirmation").to_str
    )
  end
  
  # def invoice_notification(order_id)
  #   
  #   @order = Order.find_by(:id => order_id)
  #   
  #   mail(
  #        :to => @order.account.user.email,
  #        :bcc => "sales@247officesupply.com",
  #        :subject => "24/7 Office Supply - Invoice Notification #{@order.number}", 
  #        :text => render_to_string("order_mailer/order_confirmation").to_str
  #   )
  # end
  
  def invoice_notification(order_id)
    @order = Order.find_by(:id => order_id)
    @invoice = @order
    attachments["INV_#{@order.number}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:pdf => "INV_#{@order.number}", :template => 'shop/view_invoice.html.erb', :layout => "admin_print")
    )
    # self.instance_variable_set(:@lookup_context, nil)
    mail(
         :to => @order.account.user.email,
         :bcc => "sales@247officesupply.com",
         :subject => "Invoice Notification #{@order.number}", 
         :text => render_to_string("order_mailer/order_confirmation").to_str
    )
  end
  
  # invoice_notification
  
end