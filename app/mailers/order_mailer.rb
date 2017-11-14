class OrderMailer < ApplicationMailer
  
  def order_confirmation(order_id, options = {})
    
    @order = Order.find_by(:id => order_id)
    
    defaults = {
      :from => "24\/7 Office Supply <orders@247officesupply.com>",
      :to => @order.email
    }
    options = defaults.merge(options)

    email = mail(
      :to => options[:to],
      :cc => options[:cc],
      :bcc => options[:bcc],
      :subject => "Order Notification #{@order.number}", 
      :text => render_to_string("order_mailer/order_confirmation").to_str
    )
    @email_delivery = EmailDelivery.create({
      addressable_type: 'User',
      addressable_id: @order.user_id,
      to_email: @order.email,
      body: email[:text].to_s,
      eventable_type: 'Order',
      eventable_id: @order.id
    })
    email.mailgun_variables = {message_id: @email_delivery.id}
  end
  
  def invoice_notification(order_id, options = {})
     
    @order = Order.find_by(:id => order_id)

    bill_to_address = (@order.bill_to_email.nil? || (@order.bill_to_email == @order.email) ) ? nil : @order.bill_to_email
    
    defaults = {
      :from => "24\/7 Office Supply <orders@247officesupply.com>",
      :to => @order.email,
      :cc => bill_to_address
    }
    options = defaults.merge(options)
    
    @invoice = @order
    attachments["INV_#{@order.number}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:pdf => "INV_#{@order.number}", :template => 'shop/view_invoice.html.erb', :layout => "admin_print")
    )
    attachments["INV_#{@order.number}.xls"] = render_to_string(:pdf => "INV_#{@order.number}", :template => 'shop/view_invoice.xls.erb')
    
    email = mail(
         :to => options[:to],
         :cc => options[:cc],
         :bcc => options[:bcc],
         :subject => "Invoice Notification #{@order.number}", 
         :text => render_to_string("order_mailer/invoice_notification").to_str
    )
    @email_delivery = EmailDelivery.create({
      addressable_type: 'User',
      addressable_id: @order.user_id,
      to_email: @order.email,
      body: email[:text].to_s,
      eventable_type: 'Order',
      eventable_id: @order.id
    })
    email.mailgun_variables = {message_id: @email_delivery.id}
  end

  def order_failed_authorization(order_id, options = {})

    @order = Order.find_by(:id => order_id)

    defaults = {
      :from => "24\/7 Office Supply <orders@247officesupply.com>",
      :to => 'orders@247officesupply.com'
    }
    options = defaults.merge(options)

    email = mail(
         :to => options[:to],
         :cc => options[:cc],
         :bcc => options[:bcc],
         :subject => "Failed payment authorization for order #{@order.number}",
         :text => render_to_string("order_mailer/order_failed_authorization").to_str
    )
    @email_delivery = EmailDelivery.create({
      addressable_type: 'User',
      addressable_id: @order.user_id,
      to_email: @order.email,
      body: email[:text].to_s,
      eventable_type: 'Order',
      eventable_id: @order.id
    })
    email.mailgun_variables = {message_id: @email_delivery.id}
  end
end