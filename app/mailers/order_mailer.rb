class OrderMailer < ApplicationMailer
  
  default from: "24\/7 Office Supply <orders@247officesupply.com>"
  
  def order_confirmation(order_id, options = {})
    
    @order = Order.find_by(:id => order_id)
    
    defaults = {
      :to => @order.email
    }
    options = defaults.merge(options)
    
    mail(
         :to => options[:to],
         :bcc => "sales@247officesupply.com",
         :subject => "Order Notification #{@order.number}", 
         :text => render_to_string("order_mailer/order_confirmation").to_str
    )
  end
  
  def invoice_notification(order_id, options = {})
     
    @order = Order.find_by(:id => order_id)
    
    bill_to_address = (@order.bill_to_email.nil? || (@order.bill_to_email == @order.email) ) ? nil : @order.bill_to_email
    
    defaults = {
      :to => @order.email,
      :cc => bill_to_address
    }
    options = defaults.merge(options)
    
    @invoice = @order
    attachments["INV_#{@order.number}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:pdf => "INV_#{@order.number}", :template => 'shop/view_invoice.html.erb', :layout => "admin_print")
    )
    attachments["INV_#{@order.number}.xls"] = render_to_string(:pdf => "INV_#{@order.number}", :template => 'shop/view_invoice.xls.erb')
    
    mail(
         :to => options[:to],
         :cc => options[:cc],
         :bcc => "sales@247officesupply.com",
         :subject => "Invoice Notification #{@order.number}", 
         :text => render_to_string("order_mailer/invoice_notification").to_str
    )
  end
  
end