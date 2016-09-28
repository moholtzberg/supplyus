class OrdersController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    authorize! :read, Order
    
    @orders = Order.is_complete.includes({:account => [:group]}, {:order_line_items => [:line_item_shipments, :line_item_fulfillments]}, :order_tax_rate, :order_payment_applications => [:payment]).unshipped
    
    # if params[:account_name].present?
    #   puts "ACCOUNTS -"
    #   account_id = Account.find_by(:name => params[:account_name])
    #   @orders = @orders.where(account_id: account_id)
    # end
    #
    # if params[:is_complete].present?
    #    puts "ORDERS - COMPLETE"
    #    @orders = @orders.is_complete
    # end
    #
    # if params[:shipped].present?
    #   puts "ORDERS - SHIPPED"
    #   @orders = @orders.shipped
    # else
    #   puts "ORDERS - UNSHIPPED"
    #   @orders = @orders.unshipped
    # end
    #
    # if params[:fulfilled].present?
    #   puts "ORDERS - FULFILLED"
    #   @orders = @orders.fulfilled
    # else
    #   puts "ORDERS - UNFULFILLED"
    #   @orders = @orders.unfulfilled
    # end
    #
    if params[:term].present?
      puts "ORDERS - LOOKUP"
      @orders = @orders.lookup(params[:term]) if params[:term].present?
    end
    
    @orders = @orders.order(sort_column + " " + sort_direction)
    @orders = @orders.paginate(:page => params[:page], :per_page => 20)
    respond_to do |format|
      format.html
      format.json { render :json => @orders }
    end
  end
  
  def shipped
    authorize! :read, Order
    @orders = Order.is_complete.includes({:account => [:group]}, {:order_line_items => [:line_item_shipments, :line_item_fulfillments]}, :order_tax_rate, :order_payment_applications => [:payment]).shipped
    unless params[:term].blank?
      @orders = @orders.lookup(params[:term]) if params[:term].present?
    end
    @orders = @orders.order(sort_column + " " + sort_direction)
    @orders = @orders.paginate(:page => params[:page], :per_page => 20)
    render "index"
  end
  
  def fulfilled
    authorize! :read, Order
    @orders = Order.is_complete.includes({:account => [:group]}, {:order_line_items => [:line_item_shipments, :line_item_fulfillments]}, :order_tax_rate, :order_payment_applications => [:payment]).fulfilled
    unless params[:term].blank?
      @orders = @orders.lookup(params[:term]) if params[:term].present?
    end
    @orders = @orders.order(sort_column + " " + sort_direction)
    @orders = @orders.paginate(:page => params[:page], :per_page => 20)
    render "index"
  end
  
  def unfulfilled
    authorize! :read, Order
    @orders = Order.is_complete.includes({:account => [:group]}, {:order_line_items => [:line_item_shipments, :line_item_fulfillments]}, :order_tax_rate, :order_payment_applications => [:payment]).unfulfilled
    unless params[:term].blank?
      @orders = @orders.lookup(params[:term]) if params[:term].present?
    end
    @orders = @orders.order(sort_column + " " + sort_direction)
    @orders = @orders.paginate(:page => params[:page], :per_page => 20)
    render "index"
  end
  
  def locked
    authorize! :read, Order
    @orders = Order.is_complete.includes({:account => [:group]}, {:order_line_items => [:line_item_shipments, :line_item_fulfillments]}, :order_tax_rate, :order_payment_applications => [:payment]).is_locked
    unless params[:term].blank?
      @orders = @orders.lookup(params[:term]) if params[:term].present?
    end
    @orders = @orders.paginate(:page => params[:page], :per_page => 20)
    render "index"
  end
  
  def incomplete
    authorize! :read, Order
    @orders = Order.is_incomplete.includes(:account, :order_line_items, :order_tax_rate)
    unless params[:term].blank?
      @orders = @orders.lookup(params[:term]) if params[:term].present?
    end
    @orders = @orders.paginate(:page => params[:page], :per_page => 20)
    render "index"
  end
  
  def new
    authorize! :create, Order
    if params[:account_id]
      @accounts = Account.find_by(:id => params[:account_id])
      @order = Order.create(:account_id => params[:account_id])
    else
      @accounts = Account.all
      @order = Order.create()
    end
    @items = Item.all
    @order.order_line_items.build
    @order_line_item = OrderLineItem.new
  end
  
  def show
    authorize! :read, Order
    @order = Order.find(params[:id])
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
    @order = Order.find(params[:id])
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
    order = Order.find_by(:id => params[:id])
    OrderMailer.order_notification(order.id).deliver_later
  end
  
  def resend_invoice
    order = Order.find_by(:id => params[:id])
    OrderMailer.invoice_notification(order.id).deliver_later
  end
  
  def edit
    authorize! :update, Order
    @order = Order.find(params[:id])
    @accounts = Account.all.order(:name)
    @order_line_item = OrderLineItem.new
    @items = Item.all
  end
  
  def update
    authorize! :update, Order
    @order = Order.find(params[:id])
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
  end
  
  def lock
    authorize! :update, Order
    @order_id = params[:id]
    @order = Order.find_by(:id => @order_id)
    @order.locked = true
    @order.save
  end

  private

  def order_params
    params.require(:order).permit(:account_id, :number, :email, :po_number, :completed_at, :notes, :shipping_method, :shipping_amount, :tax_rate, :tax_amount, :bill_to_account_name, :bill_to_attention, :bill_to_address_1, :bill_to_address_2, :bill_to_city, :bill_to_state, :bill_to_zip, :bill_to_phone, :bill_to_email, :ship_to_account_name, :ship_to_attention, :ship_to_address_1, :ship_to_address_2, :ship_to_city, :ship_to_state, :ship_to_zip, :ship_to_phone)
  end

  def sort_column
    related_columns = Order.reflect_on_all_associations(:belongs_to).map {|a| a.klass.column_names.map {|col| "#{a.klass.table_name}.#{col}"}}
    columns = Order.column_names.map {|a| "orders.#{a}" }
    columns.push(related_columns).flatten!.uniq!
    columns.include?(params[:sort]) ? params[:sort] : "orders.id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end