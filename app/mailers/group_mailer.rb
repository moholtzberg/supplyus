class GroupMailer < ApplicationMailer
  
  default from: "24\/7 Office Supply <orders@247officesupply.com>"
  
  def statement_notification(group_id, from, to, **args)
    @group = Group.find_by(:id => group_id)
    @accounts = @group.accounts
    @from = DateTime.strptime(from, '%m/%d/%y').kind_of?(Date) ? DateTime.strptime(from, '%m/%d/%y') : DateTime.current
    @to = DateTime.strptime(to, '%m/%d/%y').kind_of?(Date) ? DateTime.strptime(to, '%m/%d/%y') : DateTime.current
    @orders = Order.where(:account_id => @accounts.ids).unpaid
    
    attachments["#{@group.name}_Statement_#{@from.strftime("%Y_%m_%d")}_to_#{@to.strftime("%Y_%m_%d")}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:template => 'groups/statements.html.erb', :layout => 'admin_print'),
      :print_media_type => true, :page_size => 'Letter', :orientation => 'Landscape'
    )
    
    @orders.by_date_range(@from, @to).fulfilled.unpaid.each do |order|
      
      @invoice = order
      @order = order
      attachments["INV_#{order.number}.pdf"] = WickedPdf.new.pdf_from_string(
        render_to_string(:template => 'shop/view_invoice.html.erb', :layout => "admin_print"),
        :print_media_type => true, :page_size => 'Letter'
      )
      
    end
    
    email = mail(
         :to => "#{args[:email].present? ? args[:email] : 'moholtzberg@gmail.com'}",
         :bcc => "sales@247officesupply.com",
         :subject => "Group Statement Notification - #{@group.name}", 
         :text => render_to_string("groups/statements").to_str
    )
    @email_delivery = EmailDelivery.create({
      addressable_type: 'Group',
      addressable_id: @group.id,
      to_email: "#{args[:email].present? ? args[:email] : 'moholtzberg@gmail.com'}",
      body: email[:text].to_s
    })
    headers['X-Mailgun-Variables'] = @email_delivery.id
  end
  
end