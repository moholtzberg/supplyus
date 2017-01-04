class CustomersController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  respond_to :html, :json
  
  def index
    authorize! :read, Customer
    @customers = Customer.order(sort_column + " " + sort_direction).includes(:group)
    if current_user.has_role?(:super_admin) || current_user.has_role?(:Support)
    else
      @customers = @customers.where(:sales_rep_id => current_user.id)
    end
    unless params[:term].blank?
      @customers = @customers.lookup(params[:term]) if params[:term].present?
    end
    @customers = @customers.paginate(:page => params[:page], :per_page => 10)
    respond_to do |format|
      format.html
      msg = @customers.map {|a| 
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
    authorize! :create, Customer
    @customer = Customer.new
  end
  
  def edit
    authorize! :create, Customer
    @customer = Customer.find(params[:id])
  end
  
  def show
    authorize! :read, Customer
    @customer = Customer.find(params[:id])
    puts @customer.inspect
    @orders = Order.where(account_id: @customer.id).includes(:order_line_items).order(:completed_at)
    @item_prices = AccountItemPrice.where(account_id: @customer.id).includes(:item)
  end
  
  def create
    authorize! :create, Customer
    # if params[:use_ship_to_address] == true
      params[:customer][:bill_to_address_1] = params[:customer][:address_1] unless !params[:customer][:bill_to_address_1].blank?
      params[:customer][:bill_to_address_2] = params[:customer][:address_2] unless !params[:customer][:bill_to_address_2].blank?
      params[:customer][:bill_to_city] = params[:customer][:city] unless !params[:customer][:bill_to_city].blank?
      params[:customer][:bill_to_state] = params[:customer][:state] unless !params[:customer][:bill_to_state].blank?
      params[:customer][:bill_to_zip] = params[:customer][:zip] unless !params[:customer][:bill_to_zip].blank?
      params[:customer][:bill_to_phone] = params[:customer][:phone] unless !params[:customer][:bill_to_phone].blank?
      params[:customer][:bill_to_email] = params[:customer][:email] unless !params[:customer][:bill_to_email].blank?
      params[:customer][:is_taxable] = true unless params[:customer][:is_taxable] != 1
      params[:customer][:sales_rep_name] = current_user.email unless !params[:customer][:sales_rep_name].blank?
    # end
    @customer = Customer.new(account_params)
    if @customer.save
      @customers = Customer.order(sort_column + " " + sort_direction).includes(:group)
      
      if current_user.has_role?(:super_admin) || current_user.has_role?(:Support)
      else
        @customers = @customers.where(:sales_rep_id => current_user.id)
      end
      
      @customers = @customers.lookup(@customer.name)
      @customers = @customers.paginate(:page => params[:page], :per_page => 10)
    end
  end
  
  def update
    authorize! :update, Customer
    params[:customer][:bill_to_address_1] = params[:customer][:address_1] unless !params[:customer][:bill_to_address_1].blank?
    params[:customer][:bill_to_address_2] = params[:customer][:address_2] unless !params[:customer][:bill_to_address_2].blank?
    params[:customer][:bill_to_city] = params[:customer][:city] unless !params[:customer][:bill_to_city].blank?
    params[:customer][:bill_to_state] = params[:customer][:state] unless !params[:customer][:bill_to_state].blank?
    params[:customer][:bill_to_zip] = params[:customer][:zip] unless !params[:customer][:bill_to_zip].blank?
    params[:customer][:bill_to_phone] = params[:customer][:phone] unless !params[:customer][:bill_to_phone].blank?
    params[:customer][:bill_to_email] = params[:customer][:email] unless !params[:customer][:bill_to_email].blank?
    params[:customer][:is_taxable] = true unless params[:customer][:is_taxable] != 1
    @customer = Customer.find_by(:id => params[:id])
    if @customer.update_attributes(account_params)
      @customers = Customer.order(sort_column + " " + sort_direction).includes(:group)
      
      if current_user.has_role?(:super_admin) || current_user.has_role?(:Support)
      else
        @customers = @customers.where(:sales_rep_id => current_user.id)
      end
      
      @customers = @customers.lookup(@customer.name)
      @customers = @customers.paginate(:page => params[:page], :per_page => 10)
      respond_to do |format|
        format.html
        format.js
      end
    end
  end
  
  def statements
    authorize! :read, Customer
    @customer = Customer.find_by(:id => params[:id])
    puts params[:from_date]
    @from = Time.strptime(params[:from_date], '%m/%d/%y').kind_of?(Date) ? Time.strptime(params[:from_date], '%m/%d/%y') : DateTime.current
    @to = Time.strptime(params[:to_date], '%m/%d/%y').kind_of?(Date) ? Time.strptime(params[:to_date], '%m/%d/%y') : DateTime.current
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "#{@customer.number}_statement", :title => "#{@customer.name} statement", :layout => 'admin_print.html.erb', :page_size => 'Letter', :background => false,:orientation => 'Landscape', :template => 'accounts/statements.html.erb', :print_media_type => true, :show_as_html => params[:debug].present?
      end
    end
  end
  
  private

  def account_params
    params.require(:customer).permit(:name, :sales_rep_name, :email, :address_1, :address_2, :city, :state, :zip, :phone, :fax, :email, :group_name, :credit_terms, :credit_limit, :quickbooks_id, :bill_to_address_1, :bill_to_address_2, :bill_to_city, :bill_to_state, :bill_to_zip, :bill_to_phone, :bill_to_email, :is_taxable)
  end

  def sort_column
    Customer.column_names.include?(params[:sort]) ? params[:sort] : "accounts.name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end