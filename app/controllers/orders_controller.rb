class OrdersController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    @orders = Order.is_complete.includes(:account, {:order_line_items => [:line_item_shipments, :line_item_fulfillments]}).open
    @orders = @orders.order(sort_column + " " + sort_direction)
    @orders = @orders.paginate(:page => params[:page], :per_page => 10)
  end
  
  def shipped
    @orders = Order.is_complete.includes(:account, {:order_line_items => [:line_item_shipments, :line_item_fulfillments]}).shipped
    @orders = @orders.paginate(:page => params[:page], :per_page => 10)
    render "index"
  end
  
  def locked
    @orders = Order.is_locked.includes(:account, :order_line_items)
    @orders = @orders.paginate(:page => params[:page], :per_page => 10)
    render "index"
  end
  
  def incomplete
    @orders = Order.open.is_incomplete.includes(:account, :order_line_items)
    @orders = @orders.paginate(:page => params[:page], :per_page => 10)
    render "index"
  end
  

  
  def new
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
  
  def edit
    @order = Order.find(params[:id])
    @accounts = Account.all
    @order_line_item = OrderLineItem.new
    @items = Item.all
  end
  
  def update
    @order = Order.find_by(:id => params[:id])
    puts "----------> #{params[:id]}"
    puts "----------> #{@order.inspect}"
    @order.update_attributes(order_params)
    @orders = Order.all
    # if @order.save
    #   render
    # end
    
  end
  
  def create
    
  end
  
  def lock
    @order_id = params[:id]
    @order = Order.find_by(:id => @order_id)
    @order.locked = true
    @order.save
  end

  private

  def order_params
    params.require(:order).permit(:account_id, :number, :po_number, :bill_to_attention, :bill_to_address_1, :bill_to_address_2, :bill_to_city, :bill_to_state, :bill_to_zip, :bill_to_phone, :ship_to_attention, :ship_to_address_1, :ship_to_address_2, :ship_to_city, :ship_to_state, :ship_to_zip, :ship_to_phone)
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