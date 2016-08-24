class PurchaseOrderReceiptsController < ApplicationController
  layout "admin"
  
  def new
    authorize! :create, Shipment
    @purchase_order = PurchaseOrder.find_by(:id => params[:purchase_order_id])
    @purchase_order_receipt = PurchaseOrderReceipt.new(:purchase_order_id => @purchase_order.id)
    @line_items = PurchaseOrderLineItem.where(:purchase_order_id => @purchase_order.id)
  end
  
  def create
    authorize! :create, PurchaseOrderReceipt
    shipment = PurchaseOrderReceipt.new(:purchase_order_id => params[:purchase_order_id], :date => params["purchase_order_receipt"]["ship_date"])
    
    params[:lines].each do |line|
      if line[1]["quantity_receive_now"].to_i > 0
        shipment.purchase_order_line_item_receipts.new(:purchase_order_line_item_id => line[1]["purchase_order_line_item_id"], :quantity_received => line[1]["quantity_receive_now"])
      end
    end
    
    if shipment.save
      redirect_to purchase_order_path(params[:purchase_order_id])
    end
  end
  
end