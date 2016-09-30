class GroupMailer < ApplicationMailer
  
  default from: "24\/7 Office Supply <orders@247officesupply.com>"
  
  def statement_notification(group_id, from, to, **args)
    @group = Group.find_by(:id => group_id)
    @accounts = @group.accounts
    @from = DateTime.strptime(from, '%m/%d/%y').kind_of?(Date) ? DateTime.strptime(from, '%m/%d/%y') : DateTime.current
    @to = DateTime.strptime(to, '%m/%d/%y').kind_of?(Date) ? DateTime.strptime(to, '%m/%d/%y') : DateTime.current
    @orders = Order.includes(:order_payment_applications, :payments).where(:account_id => @accounts.ids)
    
    attachments["#{@group.name}_Statement_#{@from}_to_#{@to}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:title => "#{@group.name} statement #{@from}-#{@to}", :layout => 'admin_print.html.erb', :orientation => 'Landscape', :template => 'groups/statements.html.erb', :print_media_type => true)
    )
    
    @orders.by_date_range(@from, @to).fulfilled.unpaid.each do |order|
      
      @invoice = order
      @order = order
      attachments["INV_#{order.number}.pdf"] = WickedPdf.new.pdf_from_string(
        render_to_string(:template => 'shop/view_invoice.html.erb', :layout => "admin_print")
      )
      
    end
    
    mail(
         :to => "#{args[:email].present? ? args[:email] : 'moholtzberg@gmail.com'}",
         :bcc => "sales@247officesupply.com",
         :subject => "Group Statement Notification - #{@group.name}", 
         :text => render_to_string("groups/statements").to_str
    )
    
  end
  
end