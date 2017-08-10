class CustomersController < ApplicationController
  layout "admin"
  respond_to :html, :json
  
  def datatables
    authorize! :read, Customer
    render json: CustomerDatatable.new(view_context)
  end

  def autocomplete
    authorize! :read, Customer
    @customers = Customer.joins(:main_address).includes(:group)
    if current_user.has_role?(:super_admin) || current_user.has_role?(:Support)
    else
      @customers = @customers.where(:sales_rep_id => current_user.id)
    end
    unless params[:term].blank?
      @customers = @customers.lookup(params[:term]) if params[:term].present?
    end
    @customers = @customers.paginate(:page => params[:page], :per_page => 10)
    msg = @customers.map {|a| 
      {
        :label => "#{a.name} #{a.group_name.present? ? "(" + a.group_name + ")" : nil}", :value => "#{a.name}",
        :name => "#{a.name}",
        :address_1 => "#{a.address_1}", :address_2 => "#{a.address_2}", :city => "#{a.city}", 
        :state => "#{a.state}", :zip => "#{a.zip}", :phone => "#{a.phone}", :email => "#{a.email}"
      } 
    }
    render :json => msg
  end

  def index
    authorize! :read, Customer
  end
  
  def new
    authorize! :create, Customer
    @customer = Customer.new
    @customer.build_main_address
  end
  
  def edit
    authorize! :update, Customer
    @customer = Customer.find(params[:id])
  end
  
  def show
    authorize! :read, Customer
    @customer = Customer.find(params[:id])
    puts @customer.inspect
    @orders = Order.where(account_id: @customer.id).includes(:order_line_items).order(:submitted_at)
    @item_prices = Price.where(appliable: @customer).includes(:item)
  end
  
  def create
    authorize! :create, Customer
    params[:customer][:is_taxable] = true unless params[:customer][:is_taxable] != 1
    params[:customer][:sales_rep_name] = current_user.email unless !params[:customer][:sales_rep_name].blank?
    @customer = Customer.new(account_params)
    @customer.save
  end
  
  def update
    authorize! :update, Customer
    params[:customer][:is_taxable] = true unless params[:customer][:is_taxable] != 1
    @customer = Customer.find_by(:id => params[:id])
    @customer.update_attributes(account_params)
  end

  def destroy
    authorize! :destroy, Customer
    @customer = Customer.find_by(:id => params[:id])
    @customer.destroy
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
    params.require(:customer).permit(:name, :sales_rep_name, :email, :group_name, :credit_terms, :credit_limit, :quickbooks_id, :is_taxable, :replace_items, main_address_attributes: [:address_1, :address_2, :city, :state, :zip, :phone, :fax])
  end
  
end