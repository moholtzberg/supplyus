class OrdersController < ApplicationController
  layout 'admin'
  before_action :set_order, only:
    %i[show invoice resend_order resend_invoice edit update destroy
       lock approve submit cancel credit_hold remove_hold expand]

  def datatables
    authorize! :read, Order
    render json: OrderDatatable.new(view_context, from: params[:from], filters: params[:filters])
  end

  def autocomplete
    authorize! :read, Order
    @orders = Order.is_submitted.not_canceled.includes(
      { account: [:group], order_payment_applications: [:payment],
        order_line_items: [:line_item_shipments, :line_item_fulfillments] },
      :order_tax_rate
    )
    unless current_user.has_role?(:super_admin) || current_user.has_role?(:Support)
      @orders = @orders.where(:sales_rep_id => current_user.id)
    end
    @orders = @orders.lookup(params[:term]) if params[:term].present?
    render :json => @orders.map(&:number)
  end

  def index
    authorize! :read, Order
  end
  
  def new
    authorize! :create, Order
    if params[:account_id]
      @accounts = Account.find_by(:id => params[:account_id])
      @order = Order.create(:account_id => params[:account_id])
    else
      @accounts = Customer.all
      @order = Order.create()
    end
    @order.build_order_discount_code
    @items = Item.all
    # @order.order_line_items.build
    @order_line_item = OrderLineItem.new
  end
  
  def show
    authorize! :read, Order
    @order_line_items = @order.order_line_items.includes(:item)
    @shipments = Shipment.where(:order_id => @order.id)
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "#{@order.number}", :title => "#{@order.number}", :layout => 'admin_print.html.erb', :page_size => 'Letter', :background => false, :template => 'orders/show.html.erb', :print_media_type => true, :show_as_html => params[:debug].present?
      end
    end
  end
  
  def invoice
    authorize! :read, Order
    @order_line_items = @order.order_line_items.includes(:item, :line_item_fulfillments)
    @shipments = Shipment.where(:order_id => @order.id)
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "#{@order.number}", :title => "#{@order.number}", :layout => 'admin_print.html.erb', :page_size => 'Letter', :background => false, :template => 'orders/show.html.erb', :print_media_type => true, :show_as_html => params[:debug].present?
      end
    end
  end
  
  def resend_order
  end
  
  def resend_order_confirmation
    OrderMailer.order_confirmation(params["id"], :to => params["to"]).deliver_later
  end
  
  def resend_invoice
  end
  
  def resend_invoice_notification
    OrderMailer.invoice_notification(params["id"], :to => params["to"], :cc => params["cc"]).deliver_later
  end
  
  def edit
    authorize! :update, Order
    @order.build_order_discount_code if !@order.order_discount_code
    @accounts = Customer.all.order(:name)
    @order_line_item = OrderLineItem.new
    @items = Item.all
  end
  
  def update
    authorize! :update, Order
    params[:order][:sales_rep_id] = @order.account&.sales_rep_id unless !params[:order][:sales_rep_name].blank?
    params[:order][:credit_hold]  = @order.account&.credit_hold unless @order.account.nil?
    @order_line_item = OrderLineItem.new
    respond_to do |format|
      if @order.update_attributes(order_params)
        format.html { redirect_to @order, notice: "Order #{@order.number} was successfully updated!" }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def create
    authorize! :create, Order
    params[:order][:terms] = "terms" unless params[:order][:terms].nil? 
  end

  def destroy
    authorize! :destroy, Order
    @order.destroy
  end
  
  def lock
    authorize! :update, Order
    @order.update_attribute(:locked, !@order.locked)
    respond_to do |format|
      format.html { redirect_to action: 'edit', id: @order.id }
      format.js { render :update }
    end
  end
  
  def approve
    authorize! :update, Order
    @order.approve
    respond_to do |format|
      format.html { redirect_to action: 'edit', id: @order.id }
      format.js { render :update }
    end
  end

  def submit
    authorize! :update, Order
    @order.submit
    respond_to do |format|
      format.html { redirect_to action: 'edit', id: @order.id }
      format.js { render :update }
    end
  end

  def cancel
    authorize! :update, Order
    @order.cancel
    respond_to do |format|
      format.html { redirect_to action: 'edit', id: @order.id }
      format.js { render :update }
    end
  end
  
  def credit_hold
    authorize! :update, Order
    @order.credit_hold = !@order.credit_hold
    @order.save
    respond_to do |format|
      format.html { redirect_to action: 'edit', id: @order.id }
      format.js { render :update }
    end
  end
  
  def remove_hold
    authorize! :update, Order
    @order.remove_hold
    respond_to do |format|
      format.html { redirect_to action: 'edit', id: @order.id }
      format.js { render :update }
    end
  end

  def unpaid
    a = Account.find_by(name: params[:account_name])
    reuturn unless a&.id
    @unpaid_orders = Order.unpaid
                          .where(account_id: a.id)
    @unpaid_orders.includes(:payments, :accounts)
  end
  
  def returnable_items
    render :json => Order.find_by(number: params[:order_number])
      .order_line_items.map(&:to_form_hash).to_json
  end

  def expand; end
  
  private

  def order_params
    temp_params = params.require(:order).permit(:account_name, :state, :terms, :sales_rep_id, :sales_rep_name, :number, :email, :po_number, 
      :submitted_at, :notes, :credit_hold, :shipping_method, :shipping_amount, :tax_rate, :tax_amount, 
      :bill_to_account_name, :bill_to_attention, :bill_to_address_1, :bill_to_address_2, :bill_to_city, 
      :bill_to_state, :bill_to_zip, :bill_to_phone, :bill_to_email, :ship_to_account_name, :ship_to_attention, 
      :ship_to_address_1, :ship_to_address_2, :ship_to_city, :ship_to_state, :ship_to_zip, :ship_to_phone,
      order_discount_code_attributes: [:discount_code_id, :id])
    odc = temp_params[:order_discount_code_attributes]
    if odc && odc[:discount_code_id].empty? && !odc[:id].empty?
      odc[:_destroy] = true
      odc.delete(:discount_code_id)
    elsif odc && !odc[:discount_code_id].empty? && odc[:id].empty?
      odc.delete(:id)
    else
      temp_params.delete(:order_discount_code_attributes)
    end
    temp_params
  end

  def set_order
    @order = Order.find_by(number: params[:id])
    @order ||= Order.find_by(id: params[:id])
  end
end
