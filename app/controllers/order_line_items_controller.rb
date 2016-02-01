class OrderLineItemsController < ApplicationController
  
  def new
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
    # line_number = Order.find_by(params[:order_id]).order_line_items.last.order_line_number + 1
    OrderLineItem.create(order_line_item_params)
    @order = Order.find_by(:id => params[:order_line_item][:order_id])
    puts "-->> #{@order.inspect}"
  end
  
  def destroy
    @order = OrderLineItem.find_by(:id => params[:id]).order
    OrderLineItem.destroy(params[:id])
  end
  
  private
  
  def order_line_item_params
    params.require(:order_line_item).permit(:order_id, :item_id, :price, :quantity)
  end
  
end