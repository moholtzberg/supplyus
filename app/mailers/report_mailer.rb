class ReportMailer < ApplicationMailer
  
  default from: "24\/7 Office Supply <orders@247officesupply.com>"
  
  def sales_tax_report(email, _options = {})
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

  def item_usage_report(email, options = {})
    @from_date = options[:from_date].present? ? Date.strptime(options[:from_date], '%m/%d/%Y') : Date.strptime("01/01/16", '%m/%d/%Y')
    @to_date = options[:to_date].present? ? Date.strptime(options[:to_date], '%m/%d/%Y') : Date.today

    attachments["item_usage_#{@from_date.strftime('%m_%d_%Y')}-#{@to_date.strftime('%m_%d_%Y')}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:template => 'reports/item_usage.html.erb', :layout => 'admin_print.html.erb'), :title => "Item Usage",
      :print_media_type => true, :page_size => 'Letter', :orientation => 'Landscape'
    )
    
    email = mail(
      :to => "#{email}",
      :subject => "Item Usage Report"
    )
  end

  def item_usage_for_account_ids_report(email, options = {})
    @accounts = Customer.where(id: options[:account_ids])
    @from_date = options[:from_date].present? ? Date.strptime(options[:from_date], '%m/%d/%Y') : Date.strptime("01/01/16", '%m/%d/%Y')
    @to_date = options[:to_date].present? ? Date.strptime(options[:to_date], '%m/%d/%Y') : Date.today

    attachments["item_usage_for_account_ids_#{@accounts.map(&:id).join('_')}_#{@from_date.strftime('%m_%d_%Y')}-#{@to_date.strftime('%m_%d_%Y')}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:template => 'reports/item_usage_for_account_ids.html.erb', :layout => 'admin_print.html.erb'), :title => "Item Usage For Account IDs",
      :print_media_type => true, :page_size => 'Letter', :orientation => 'Landscape'
    )
    
    email = mail(
      :to => "#{email}",
      :subject => "Item Usage For Account IDs Report"
    )
  end

  def item_usage_by_group_report(email, options = {})
    @group = Group.find(options[:group_id])
    @from_date = options[:from_date].present? ? Date.strptime(options[:from_date], '%m/%d/%Y') : Date.strptime("01/01/16", '%m/%d/%Y')
    @to_date = options[:to_date].present? ? Date.strptime(options[:to_date], '%m/%d/%Y') : Date.today

    attachments["item_usage_by_group_#{@group.name}_#{@from_date.strftime('%m_%d_%Y')}-#{@to_date.strftime('%m_%d_%Y')}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(:template => 'reports/item_usage_by_group.html.erb', :layout => 'admin_print.html.erb'), :title => "Item Usage By Group",
      :print_media_type => true, :page_size => 'Letter', :orientation => 'Landscape'
    )
    
    email = mail(
      :to => "#{email}",
      :subject => "Item Usage By Group"
    )
  end

  def ar_aging_report(email, _options = {})
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

  def vendor_prices_report(email, _options = {})
    @items = Item.joins(order_line_items: :order)
                 .where('orders.state = \'completed\'').group('items.id')
                 .order('SUM(COALESCE(quantity,0) - COALESCE(quantity_canceled,0)) DESC')

    attachments["vendor_prices_#{Date.today.strftime('%m_%d_%Y')}.pdf"] =
      WickedPdf.new.pdf_from_string(
        render_to_string(
          template: 'reports/vendor_prices.html.erb',
          layout: 'admin_print.html.erb'
        ),
        title: 'Vendor Prices', print_media_type: true,
        page_size: 'Letter', orientation: 'Landscape'
      )

    mail(:to => email.to_s, :subject => 'Item Usage Report')
  end
end
