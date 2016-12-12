class OrderLineItemsController < ApplicationController
  
  def new
    authorize! :create, OrderLineItem
    puts params.inspect
    if params[:line_number].blank?
      @line_number = 1
    else
      @line_number = params[:line_number]
    end
    puts "---> line number => #{@line_number}"
    @order = Order.find_by(:id => params[:id])
    @items = Item.all
  end
  
  def create
    authorize! :create, OrderLineItem
    # line_number = Order.find_by(params[:order_id]).order_line_items.last.order_line_number + 1
    OrderLineItem.create(order_line_item_params)
    @order = Order.find_by(:id => params[:order_line_item][:order_id])
    puts "-->> #{@order.inspect}"
  end
  
  def update
    authorize! :update, OrderLineItem
    @line_item = OrderLineItem.find_by(:id => params[:id])
    if @line_item.update_attributes(order_line_item_params)
      flash[:notice] = "\"#{@line_item.order_line_number}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
    respond_to do |format|
      format.html
      format.json do 
        respond_with_bip(@line_item)
      end
    end
  end
  
  def destroy
    authorize! :destroy, OrderLineItem
    @order = OrderLineItem.find_by(:id => params[:id]).order
    OrderLineItem.destroy(params[:id])
  end
  
  private
  
  def order_line_item_params
    params.require(:order_line_item).permit(:order_id, :item_id, :price, :quantity, :quantity_canceled, :item_number, :description)
  end
  
end