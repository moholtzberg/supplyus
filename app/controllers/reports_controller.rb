class ReportsController < ApplicationController
  layout "admin"
  def index
    
  end
  
  def sales_tax
    @from_date = 12.months.ago.beginning_of_year
    @to_date = Date.today
    if params[:format] == 'email'
      ReportMailer.sales_tax_report(current_user.email).deliver_later
      flash[:notice] = 'Report successfully sent.'
      redirect_to reports_path
      return
    else
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
  end
  
  def item_usage
    @from_date = params[:from_date].present? ? Date.strptime(params[:from_date], '%m/%d/%Y') : Date.strptime("01/01/16", '%m/%d/%Y')
    @to_date = params[:to_date].present? ? Date.strptime(params[:to_date], '%m/%d/%Y') : Date.today
    if params[:format] == 'email'
      ReportMailer.item_usage_report(current_user.email, params[:from_date], params[:to_date]).deliver_later
      flash[:notice] = 'Report successfully sent.'
      redirect_to reports_path
      return
    else
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
  end
  
  def item_usage_for_account_ids
    @accounts = Customer.where(id: params[:account_ids])
    @from_date = params[:from_date].present? ? Date.strptime(params[:from_date], '%m/%d/%Y') : Date.strptime("01/01/16", '%m/%d/%Y')
    @to_date = params[:to_date].present? ? Date.strptime(params[:to_date], '%m/%d/%Y') : Date.today
    if params[:format] == 'email'
      ReportMailer.item_usage_for_account_ids_report(current_user.email, params[:from_date], params[:to_date], params[:account_ids]).deliver_later
      flash[:notice] = 'Report successfully sent.'
      redirect_to reports_path
      return
    else
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
  end

  def item_usage_by_group
    @group = Group.find(params[:group_id])
    @from_date =  params[:from_date].present? ? Date.strptime(params[:from_date], '%m/%d/%Y') : Date.strptime("01/01/16", '%m/%d/%Y')
    @to_date =  params[:to_date].present? ? Date.strptime(params[:to_date], '%m/%d/%Y') : Date.today
    if params[:format] == 'email'
      ReportMailer.item_usage_by_group_report(current_user.email, params[:from_date], params[:to_date], params[:group_id]).deliver_later
      flash[:notice] = 'Report successfully sent.'
      redirect_to reports_path
      return
    else
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
  end
  
  def ar_aging
    @orders = Order.fulfilled.unpaid
    if params[:format] == 'email'
      ReportMailer.ar_aging_report(current_user.email).deliver_later
      flash[:notice] = 'Report successfully sent.'
      redirect_to reports_path
      return
    else
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
  end
end