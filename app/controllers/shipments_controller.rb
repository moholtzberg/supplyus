class ShipmentsController < ApplicationController
  layout "admin"
  
  def new
    authorize! :create, Shipment
    @order = Order.find_by(:id => params[:order_id])
    @shipment = Shipment.new(:order_id => @order.id)
    @line_items = OrderLineItem.where(:order_id => @order.id)
  end
  
  def create
    authorize! :create, Shipment
    shipment = Shipment.new(:date => Time.now, :order_id => params[:order_id], :carrier => params[:shipment][:carrier], :ship_date => params[:shipment][:ship_date])
    
    params[:lines].each do |line|
      shipment.line_item_shipments.new(:order_line_item_id => line[1]["order_line_item_id"], :quantity_shipped => line[1]["quantity_ship_now"])
    end
    
    params[:tracking_numbers].each do |tracking|
      unless tracking[1]["number"].blank?
        shipment.tracking_numbers.new(:number => tracking[1]["number"])
      end
    end
    
    if shipment.save
      ShipmentMailer.shipment_confirmation(shipment.id).deliver_later
      redirect_to order_path(params[:order_id])
    end
  end
  
end