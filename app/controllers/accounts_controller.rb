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
      format.json {render :json => @accounts.map(&:name)}
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
    authorize! :read, Account
    @account = Account.find_by(:id => params[:id])
    puts params[:from_date]
    @from = Time.strptime(params[:from_date], '%m/%d/%y').kind_of?(Date) ? Time.strptime(params[:from_date], '%m/%d/%y') : DateTime.current
    @to = Time.strptime(params[:to_date], '%m/%d/%y').kind_of?(Date) ? Time.strptime(params[:to_date], '%m/%d/%y') : DateTime.current
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "#{@account.number}_statement", :title => "#{@account.name} statement", :layout => 'admin_print.html.erb', :page_size => 'Letter', :background => false,:orientation => 'Landscape', :template => 'accounts/statements.html.erb', :print_media_type => true, :show_as_html => params[:debug].present?
      end
    end
  end

  private

  def account_params
    params.require(:account).permit(:name, :email, :address_1, :address_2, :city, :state, :zip, :phone, :fax, :email, :group_name, :credit_terms, :credit_limit, :quickbooks_id, :bill_to_address_1, :bill_to_address_2, :bill_to_city, :bill_to_state, :bill_to_zip, :bill_to_phone, :bill_to_email)
  end

  def sort_column
    Account.column_names.include?(params[:sort]) ? params[:sort] : "accounts.name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end