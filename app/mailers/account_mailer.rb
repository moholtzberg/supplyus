class AccountMailer < ApplicationMailer
  
  default from: "24\/7 Office Supply <orders@247officesupply.com>"
  
  def statement_notification(account_id, from, to, **args)
    @account = Account.find(account_id)
    @from = DateTime.strptime(from, '%m/%d/%y').kind_of?(Date) ? DateTime.strptime(from, '%m/%d/%y') : DateTime.current
    @to = DateTime.strptime(to, '%m/%d/%y').kind_of?(Date) ? DateTime.strptime(to, '%m/%d/%y') : DateTime.current
    @orders = Order.where(:account_id => @account.id).unpaid
    
    attachments["#{@account.name}_Statement_#{@from.strftime("%Y_%m_%d")}_to_#{@to.strftime("%Y_%m_%d")}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:layout => 'admin_print', :template => 'accounts/statements.html.erb'),
      :orientation => 'Landscape', :print_media_type => true
    )
    
    @orders.by_date_range(@from, @to).fulfilled.unpaid.each do |order|
      @invoice = order
      @order = order
      attachments["INV_#{order.number}.pdf"] = WickedPdf.new.pdf_from_string(
        render_to_string(:template => 'shop/view_invoice.html.erb', :layout => "admin_print"),
        :orientation => 'Landscape', :print_media_type => true
      )
    end
    email = mail(
        :to => "#{args[:email].present? ? args[:email] : 'moholtzberg@gmail.com'}",
        :bcc => "sales@247officesupply.com",
        :subject => "Account Statement Notification - #{@account.name}",
        :text => render_to_string("accounts/statements").to_str
    )
    @email_delivery = EmailDelivery.create({
      addressable_type: 'Account',
      addressable_id: @account.id,
      to_email: "#{args[:email].present? ? args[:email] : 'moholtzberg@gmail.com'}",
      body: email[:text].to_s
    })
    headers['X-Mailgun-Variables'] = @email_delivery.id
  end

  def statement_all_notification(account_id, from, to, **args)
    @account = Account.find(account_id)
    @from = DateTime.strptime(from, '%m/%d/%y').kind_of?(Date) ? DateTime.strptime(from, '%m/%d/%y') : DateTime.current
    @to = DateTime.strptime(to, '%m/%d/%y').kind_of?(Date) ? DateTime.strptime(to, '%m/%d/%y') : DateTime.current
    @orders = Order.where(:account_id => @account.id)

    attachments["#{@account.name}_Statement_#{@from.strftime("%Y_%m_%d")}_to_#{@to.strftime("%Y_%m_%d")}.pdf"] = WickedPdf.new.pdf_from_string(
        render_to_string(:layout => 'admin_print.html.erb', :template => 'accounts/statements.html.erb'),
        :orientation => 'Landscape', :print_media_type => true
    )

    @orders.by_date_range(@from, @to).shipped.each do |order|

      @invoice = order
      @order = order
      attachments["INV_#{order.number}.pdf"] = WickedPdf.new.pdf_from_string(
          render_to_string(:template => 'shop/view_invoice.html.erb', :layout => "admin_print"),
          :orientation => 'Landscape', :print_media_type => true
      )

    end
    email = mail(
        :to => "#{args[:email].present? ? args[:email] : 'moholtzberg@gmail.com'}",
        :bcc => "sales@247officesupply.com",
        :subject => "Account Statement Notification - #{@account.name}",
        :text => render_to_string("accounts/statements").to_str
    )
    @email_delivery = EmailDelivery.create({
      addressable_type: 'Account',
      addressable_id: @account.id,
      to_email: "#{args[:email].present? ? args[:email] : 'moholtzberg@gmail.com'}",
      body: email[:text].to_s
    })
    headers['X-Mailgun-Variables'] = @email_delivery.id
  end

end