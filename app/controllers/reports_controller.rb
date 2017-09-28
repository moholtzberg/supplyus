class ReportsController < ApplicationController
  layout 'admin'

  def index; end

  def sales_tax
    @from_date = 12.months.ago.beginning_of_year
    @to_date = Date.today
    send_report && return if params[:format] == 'email'
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        render :pdf => "sales_tax_#{@from_date.strftime('%m_%Y')}-#{@to_date.strftime('%m_%Y')}",
          :title => "Sales Tax", :layout => 'admin_print.html.erb', :page_size => 'Letter',
          :background => false, :template => 'reports/sales_tax.html.erb', :print_media_type => true,
          :show_as_html => params[:debug].present?
      end
      format.xls
    end
  end
  
  def item_usage
    @from_date = params[:from_date].present? ? Date.strptime(params[:from_date], '%m/%d/%Y') : Date.strptime("01/01/16", '%m/%d/%Y')
    @to_date = params[:to_date].present? ? Date.strptime(params[:to_date], '%m/%d/%Y') : Date.today
    send_report && return if params[:format] == 'email'
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        render :pdf => "item_usage_#{@from_date.strftime('%m_%d_%Y')}-#{@to_date.strftime('%m_%d_%Y')}",
          :title => "Item Usage", :layout => 'admin_print.html.erb', :page_size => 'Letter',
          :background => false, :template => 'reports/item_usage.html.erb', :print_media_type => true,
          :show_as_html => params[:debug].present?
      end
      format.xls
    end
  end
  
  def item_usage_for_account_ids
    @accounts = Customer.where(id: params[:account_ids])
    @from_date = params[:from_date].present? ? Date.strptime(params[:from_date], '%m/%d/%Y') : Date.strptime("01/01/16", '%m/%d/%Y')
    @to_date = params[:to_date].present? ? Date.strptime(params[:to_date], '%m/%d/%Y') : Date.today
    send_report && return if params[:format] == 'email'
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        render :pdf => "item_usage_for_account_ids_#{@accounts.map(&:id).join('_')}_#{@from_date.strftime('%m_%d_%Y')}-#{@to_date.strftime('%m_%d_%Y')}",
          :title => "Item Usage For Accounts", :layout => 'admin_print.html.erb', :page_size => 'Letter',
          :background => false, :template => 'reports/item_usage_for_account_ids.html.erb', :print_media_type => true,
          :show_as_html => params[:debug].present?
      end
      format.xls
    end
  end

  def item_usage_by_group
    @group = Group.find(params[:group_id])
    @from_date =  params[:from_date].present? ? Date.strptime(params[:from_date], '%m/%d/%Y') : Date.strptime("01/01/16", '%m/%d/%Y')
    @to_date =  params[:to_date].present? ? Date.strptime(params[:to_date], '%m/%d/%Y') : Date.today
    send_report && return if params[:format] == 'email'
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        render :pdf => "item_usage_by_group_#{@group.name}_#{@from_date.strftime('%m_%d_%Y')}-#{@to_date.strftime('%m_%d_%Y')}",
          :title => "Item Usage By Group", :layout => 'admin_print.html.erb', :page_size => 'Letter',
          :background => false, :template => 'reports/item_usage_by_group.html.erb', :print_media_type => true,
          :show_as_html => params[:debug].present?
      end
      format.xls
    end
  end
  
  def ar_aging
    @orders = Order.fulfilled.unpaid
    send_report && return if params[:format] == 'email'
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        render :pdf => "ar_aging_#{Date.today.strftime('%m_%d_%Y')}",
          :title => "AR Aging", :layout => 'admin_print.html.erb', :page_size => 'Letter',
          :background => false, :template => 'reports/ar_aging.html.erb', :print_media_type => true,
          :show_as_html => params[:debug].present?
      end
      format.xls
    end
  end

  def vendor_prices
    @items = Item.joins(order_line_items: :order)
                 .where('orders.state = \'completed\'').group('items.id')
                 .order('SUM(COALESCE(quantity,0) - COALESCE(quantity_canceled,0)) DESC')
    send_report && return if params[:format] == 'email'
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        render :pdf => "vendor_prices_#{Date.today.strftime('%m_%d_%Y')}",
          :title => "Vendor Prices", :layout => 'admin_print.html.erb', :page_size => 'Letter',
          :background => false, :template => 'reports/vendor_prices.html.erb', :print_media_type => true,
          :show_as_html => params[:debug].present?
      end
      format.xls
    end
  end

  def send_report
    ReportMailer.send("#{params[:action]}_report",
                      current_user.email,
                      from_date: params[:from_date],
                      to_date: params[:to_date],
                      account_ids: params[:account_ids],
                      group_id: params[:group_id]).deliver_now
    flash[:notice] = 'Report successfully sent.'
    redirect_to reports_path
  end
end
