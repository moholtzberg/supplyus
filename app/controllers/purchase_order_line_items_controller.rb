class PurchaseOrderLineItemsController < ApplicationController
  
  def new
    authorize! :create, PuchaseOrderLineItem
    puts params.inspect
    if params[:line_number].blank?
      @line_number = 1
    else
      @line_number = params[:line_number]
    end
    puts "---> line number => #{@line_number}"
    @order = PurchaseOrder.find_by(:id => params[:id])
    @items = Item.all
  end
  
  def create
    authorize! :create, PurchaseOrderLineItem
    PurchaseOrderLineItem.create(purchase_order_line_item_params)
    @purchase_order = PurchaseOrder.find_by(:id => params[:purchase_order_line_item][:purchase_order_id])
  end
  
  def update
    authorize! :update, PurchaseOrderLineItem
    @line_item = PurchaseOrderLineItem.find_by(:id => params[:id])
    puts purchase_order_line_item_params.inspect
    if @line_item.update_attributes(purchase_order_line_item_params)
      flash[:notice] = "\"#{@line_item.purchase_order_line_number}\" has been updated"
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
    authorize! :destroy, PurchaseOrderLineItem
    @purchase_order = PurchaseOrderLineItem.find_by(:id => params[:id]).purchase_order
    PurchaseOrderLineItem.destroy(params[:id])
  end
  
  private
  
  def purchase_order_line_item_params
    params.require(:purchase_order_line_item).permit(:purchase_order_id, :item_id, :price, :quantity, :quantity_canceled, :item_number, :order_line_item_id)
  end
  
end