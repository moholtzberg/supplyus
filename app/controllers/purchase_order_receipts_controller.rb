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

    shipment = PurchaseOrderReceipt.new(purchase_order_receipt_params)

    if shipment.save
      redirect_to purchase_order_path(params[:purchase_order_id])
    end
  end

  def destroy
    @purchase_order_receipt = PurchaseOrderReceipt.find(params[:id])
    @purchase_order_receipt.destroy!
    respond_to do |format|
      format.js
    end
  end

  def purchase_order_receipt_params
    params.require(:purchase_order_receipt).permit(:date, :purchase_order_id, purchase_order_line_item_receipts_attributes: [:purchase_order_line_item_id, :bin_id, :quantity_received])
  end
  
end