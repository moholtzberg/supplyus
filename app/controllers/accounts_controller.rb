class AccountsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    authorize! :read, Account
    @accounts = Account.joins(:main_address).order(sort_column + " " + sort_direction).includes(:group)
    unless params[:term].blank?
      @accounts = @accounts.lookup(params[:term]) if params[:term].present?
    end
    respond_to do |format|
      format.html
      msg = @accounts.map {|a| 
        {
          :label => "#{a.name} #{a.group_name.present? ? "(" + a.group_name + ")" : nil}", :value => "#{a.name}",
          :name => "#{a.name}",
          :address_1 => "#{a.address_1}", :address_2 => "#{a.address_2}", :city => "#{a.city}", 
          :state => "#{a.state}", :zip => "#{a.zip}", :phone => "#{a.phone}", :email => "#{a.email}",
          :credit_cards => a.main_service.credit_cards.map {|cc| ["**** **** **** #{cc.last_4.to_i}", cc.id] }.to_h
        } 
      }
      format.json {render :json => msg}
      
    end
  end
  
  def new
    authorize! :create, Account
    @account = Account.new
    @account.build_main_address
  end
  
  def show
    authorize! :read, Account
    @account = Account.find(params[:id])
    puts @account.inspect
    @orders = Order.where(account_id: @account.id).includes(:order_line_items).order(:submitted_at)
    @item_prices = Price.where(appliable: @account).includes(:item)
  end
  
  def edit
    authorize! :update, Account
    @account = Account.find_by(:id => params[:id])
  end
    
  def create
    authorize! :create, Account
    params[:account][:is_taxable] = true unless params[:account][:is_taxable] != 1
    params[:account][:sales_rep_name] = current_user.email unless !params[:account][:sales_rep_name].blank?
    @account = Account.new(account_params)
    if @account.save
      @accounts = Account.joins(:main_address).order(sort_column + " " + sort_direction).includes(:group)
      @accounts = @accounts.paginate(:page => params[:page], :per_page => 25)
    end
  end
  
  def update
    authorize! :update, Account
    params[:account][:is_taxable] = true unless params[:account][:is_taxable] != 1
    @account = Account.find_by(:id => params[:id])
    if @account.update_attributes(account_params)
      @accounts = Account.joins(:main_address).order(sort_column + " " + sort_direction).includes(:group)
      @accounts = @accounts.paginate(:page => params[:page], :per_page => 25)
    else
      flash[:error] = @account.errors.full_messages.join(', ') if @account.errors.any?
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
    params.require(:account).permit(:name, :sales_rep_name, :email, :group_name, :credit_terms, :credit_limit, :quickbooks_id, :is_taxable, 
      :subscription_week_day, :subscription_month_day, :subscription_quarter_day, main_address_attributes: [:name, :address_1, :address_2, :city, :state, :zip, :phone, :fax])
  end

  def sort_column
    (Account.column_names + Address.column_names).include?(params[:sort]) ? params[:sort] : "accounts.name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end