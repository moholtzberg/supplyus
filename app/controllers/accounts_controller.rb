class AccountsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    authorize! :read, Account
    @accounts = Account.order(sort_column + " " + sort_direction)
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
    @account = Account.new(account_params)
    if @account.save
      @accounts = Account.order(sort_column + " " + sort_direction)
      @accounts = @accounts.paginate(:page => params[:page], :per_page => 25)
    end
  end
  
  def update
    authorize! :update, Account
    @account = Account.find_by(:id => params[:id])
    if @account.update_attributes(account_params)
      @accounts = Account.all
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
    params.require(:account).permit(:name, :email, :address_1, :address_2, :city, :state, :zip, :phone, :fax, :email, :group_name, :credit_terms, :credit_limit, :quickbooks_id)
  end

  def sort_column
    puts Account.column_names[0]
    Account.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end