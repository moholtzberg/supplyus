class ReportMailer < ApplicationMailer
  
  default from: "24\/7 Office Supply <orders@247officesupply.com>"
  
  def sales_tax_report(emaile)
    @from_date = 12.months.ago.beginning_of_year
    @to_date = Date.today

    attachments["sales_tax_#{@from_date.strftime('%m_%Y')}-#{@to_date.strftime('%m_%Y')}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:template => 'reports/sales_tax.html.erb', :layout => 'admin_print.html.erb'), :title => "Sales Tax",
      :print_media_type => true, :page_size => 'Letter', :orientation => 'Landscape'
    )
    
    email = mail(
      :to => "#{email}",
      :subject => "Sales Tax Report"
    )
  end

  def item_usage_report(email, from_date, to_date)
    @from_date = from_date.present? ? Date.strptime(from_date, '%m/%d/%Y') : Date.strptime("01/01/16", '%m/%d/%Y')
    @to_date = to_date.present? ? Date.strptime(to_date, '%m/%d/%Y') : Date.today

    attachments["item_usage_#{@from_date.strftime('%m_%d_%Y')}-#{@to_date.strftime('%m_%d_%Y')}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:template => 'reports/item_usage.html.erb', :layout => 'admin_print.html.erb'), :title => "Item Usage",
      :print_media_type => true, :page_size => 'Letter', :orientation => 'Landscape'
    )
    
    email = mail(
      :to => "#{email}",
      :subject => "Item Usage Report"
    )
  end

  def item_usage_for_account_ids_report(email, from_date, to_date, account_ids)
    @accounts = Customer.where(id: account_ids)
    @from_date = from_date.present? ? Date.strptime(from_date, '%m/%d/%Y') : Date.strptime("01/01/16", '%m/%d/%Y')
    @to_date = to_date.present? ? Date.strptime(to_date, '%m/%d/%Y') : Date.today

    attachments["item_usage_for_account_ids_#{@accounts.map(&:id).join('_')}_#{@from_date.strftime('%m_%d_%Y')}-#{@to_date.strftime('%m_%d_%Y')}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:template => 'reports/item_usage_for_account_ids.html.erb', :layout => 'admin_print.html.erb'), :title => "Item Usage For Account IDs",
      :print_media_type => true, :page_size => 'Letter', :orientation => 'Landscape'
    )
    
    email = mail(
      :to => "#{email}",
      :subject => "Item Usage For Account IDs Report"
    )
  end

  def item_usage_by_group_report(email, from_date, to_date, group_id)
    @group = Group.find(group_id)
    @from_date = from_date.present? ? Date.strptime(from_date, '%m/%d/%Y') : Date.strptime("01/01/16", '%m/%d/%Y')
    @to_date = to_date.present? ? Date.strptime(to_date, '%m/%d/%Y') : Date.today

    attachments["item_usage_by_group_#{@group.name}_#{@from_date.strftime('%m_%d_%Y')}-#{@to_date.strftime('%m_%d_%Y')}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:template => 'reports/item_usage_by_group.html.erb', :layout => 'admin_print.html.erb'), :title => "Item Usage By Group",
      :print_media_type => true, :page_size => 'Letter', :orientation => 'Landscape'
    )
    
    email = mail(
      :to => "#{email}",
      :subject => "Item Usage By Group"
    )
  end

  def ar_aging_report(email)
    @orders = Order.fulfilled.unpaid

    attachments["ar_aging_#{Date.today.strftime('%m_%d_%Y')}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:template => 'reports/ar_aging.html.erb', :layout => 'admin_print.html.erb'), :title => "AR Aging",
      :print_media_type => true, :page_size => 'Letter', :orientation => 'Landscape'
    )
    
    email = mail(
      :to => "#{email}",
      :subject => "AR Aging"
    )
  end
end