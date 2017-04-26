class AccountsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    authorize! :read, Account
    @accounts = Account.order(sort_column + " " + sort_direction).includes(:group)
    unless params[:term].blank?
      @accounts = @accounts.lookup(params[:term]) if params[:term].present?
    end
    respond_to do |format|
      format.html
      msg = @accounts.map {|a| 
        {
          :label => "#{a.name} #{a.group_name.present? ? "(" + a.group_name + ")" : nil}", :value => "#{a.name}",
          :name => "#{a.name}",
          :ship_to_address_1 => "#{a.ship_to_address_1}", :ship_to_address_2 => "#{a.ship_to_address_2}", :ship_to_city => "#{a.ship_to_city}", 
          :ship_to_state => "#{a.ship_to_state}", :ship_to_zip => "#{a.ship_to_zip}", :ship_to_phone => "#{a.ship_to_phone}", :ship_to_email => "#{a.email}",
          :bill_to_address_1 => "#{a.bill_to_address_1}", :bill_to_address_2 => "#{a.bill_to_address_2}", :bill_to_city => "#{a.bill_to_city}", 
          :bill_to_state => "#{a.bill_to_state}", :bill_to_zip => "#{a.bill_to_zip}", :bill_to_phone => "#{a.bill_to_phone}", :bill_to_email => "#{a.bill_to_email}"
        } 
      }
      format.json {render :json => msg}
      
    end
  end
  
  def new
    authorize! :create, Account
    @account = Account.new
  end
  
  def show
    authorize! :read, Account
    @account = Account.find(params[:id])
    puts @account.inspect
    @orders = Order.where(account_id: @account.id).includes(:order_line_items).order(:completed_at)
    @item_prices = AccountItemPrice.where(account_id: @account.id).includes(:item)
  end
  
  def edit
    authorize! :update, Account
    @account = Account.find_by(:id => params[:id])
  end
    
  def create
    authorize! :create, Account
    # if params[:use_ship_to_address] == true
      params[:account][:bill_to_address_1] = params[:account][:address_1] unless !params[:account][:bill_to_address_1].blank?
      params[:account][:bill_to_address_2] = params[:account][:address_2] unless !params[:account][:bill_to_address_2].blank?
      params[:account][:bill_to_city] = params[:account][:city] unless !params[:account][:bill_to_city].blank?
      params[:account][:bill_to_state] = params[:account][:state] unless !params[:account][:bill_to_state].blank?
      params[:account][:bill_to_zip] = params[:account][:zip] unless !params[:account][:bill_to_zip].blank?
      params[:account][:bill_to_phone] = params[:account][:phone] unless !params[:account][:bill_to_phone].blank?
      params[:account][:bill_to_email] = params[:account][:email] unless !params[:account][:bill_to_email].blank?
      params[:account][:is_taxable] = true unless params[:account][:is_taxable] != 1
      params[:account][:sales_rep_name] = current_user.email unless !params[:account][:sales_rep_name].blank?
    # end
    @account = Account.new(account_params)
    if @account.save
      @accounts = Account.order(sort_column + " " + sort_direction).includes(:group)
      @accounts = @accounts.paginate(:page => params[:page], :per_page => 25)
    end
  end
  
  def update
    authorize! :update, Account
    params[:account][:bill_to_address_1] = params[:account][:address_1] unless !params[:account][:bill_to_address_1].blank?
    params[:account][:bill_to_address_2] = params[:account][:address_2] unless !params[:account][:bill_to_address_2].blank?
    params[:account][:bill_to_city] = params[:account][:city] unless !params[:account][:bill_to_city].blank?
    params[:account][:bill_to_state] = params[:account][:state] unless !params[:account][:bill_to_state].blank?
    params[:account][:bill_to_zip] = params[:account][:zip] unless !params[:account][:bill_to_zip].blank?
    params[:account][:bill_to_phone] = params[:account][:phone] unless !params[:account][:bill_to_phone].blank?
    params[:account][:bill_to_email] = params[:account][:email] unless !params[:account][:bill_to_email].blank?
    params[:account][:is_taxable] = true unless params[:account][:is_taxable] != 1
    @account = Account.find_by(:id => params[:id])
    if @account.update_attributes(account_params)
      @accounts = Account.order(sort_column + " " + sort_direction).includes(:group)
      @accounts = @accounts.paginate(:page => params[:page], :per_page => 25)
      respond_to do |format|
        format.html
        format.js
      end
    end
  end
  
  def statements
    @account = Account.find_by(:id => params[:id])
    @from = Date.strptime(params[:from_date], '%m/%d/%y').kind_of?(Date) ? Date.strptime(params[:from_date], '%m/%d/%y') : Date.today
    @to = Date.strptime(params[:to_date], '%m/%d/%y').kind_of?(Date) ? Date.strptime(params[:to_date], '%m/%d/%y') : Date.today
    @orders = Order.where(:account_id => @account.id).unpaid
    
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "#{@account.name}_statement_#{@from}-#{@to}", :title => "#{@account.name} statement #{@from}-#{@to}", :layout => 'admin_print.html.erb', :page_size => 'Letter', :background => false, :orientation => 'Landscape', :template => 'accounts/statements.html.erb', :print_media_type => true, :show_as_html => params[:debug].present?
      end
    end
    if params[:deliver_notification]
      AccountMailer::statement_notification(@account.id, params[:from_date], params[:to_date]).deliver_later
    end
  end

  def statements_all
    @account = Account.find_by(:id => params[:id])
    @from = Date.strptime(params[:from_date], '%m/%d/%y').kind_of?(Date) ? Date.strptime(params[:from_date], '%m/%d/%y') : Date.today
    @to = Date.strptime(params[:to_date], '%m/%d/%y').kind_of?(Date) ? Date.strptime(params[:to_date], '%m/%d/%y') : Date.today
    @orders = Order.where(:account_id => @account.id)

    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "#{@account.name}_statement_#{@from}-#{@to}", :title => "#{@account.name} statement #{@from}-#{@to}", :layout => 'admin_print.html.erb', :page_size => 'Letter', :background => false, :orientation => 'Landscape', :template => 'accounts/statements.html.erb', :print_media_type => true, :show_as_html => params[:debug].present?
      end
    end
    if params[:deliver_notification]
      AccountMailer::statement_all_notification(@account.id, params[:from_date], params[:to_date]).deliver_later
    end
  end

  private

  def account_params
    params.require(:account).permit(:name, :sales_rep_name, :email, :address_1, :address_2, :city, :state, :zip, :phone, :fax, :email, :group_name, :credit_terms, :credit_limit, :quickbooks_id, :bill_to_address_1, :bill_to_address_2, :bill_to_city, :bill_to_state, :bill_to_zip, :bill_to_phone, :bill_to_email, :is_taxable)
  end

  def sort_column
    Account.column_names.include?(params[:sort]) ? params[:sort] : "accounts.name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end