class OrdersController < ApplicationController
  layout "admin"
  
  def index
    @orders = Order.all
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

  private

  def order_params
    params.require(:order).permit(:account_id, :number, :po_number, :bill_to_attention, :bill_to_address_1, :bill_to_address_2, :bill_to_city, :bill_to_state, :bill_to_zip, :bill_to_phone, :ship_to_attention, :ship_to_address_1, :ship_to_address_2, :ship_to_city, :ship_to_state, :ship_to_zip, :ship_to_phone)
  end
  
end