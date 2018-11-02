class ShipmentsController < ApplicationController
  layout 'admin'

  def new
    authorize! :create, Shipment
    @order = Order.find_by(:id => params[:order_id])
    @shipment = Shipment.new(:order_id => @order.id)
    @line_items = OrderLineItem.where(:order_id => @order.id)
  end

  def create
    authorize! :create, Shipment
    shipment = Shipment.new(:date => Time.now, :order_id => params[:order_id], :carrier => params[:shipment][:carrier], :ship_date => params[:shipment][:ship_date])
    
    params[:shipment][:line_item_shipments_attributes].each do |line|
      puts line.inspect
      if line[1]["quantity_shipped"].to_i > 0
        shipment.line_item_shipments.new(:order_line_item_id => line[1]["order_line_item_id"], :quantity_shipped => line[1]["quantity_shipped"], :bin_id => line[1]["bin_id"])
      end
    end
    
    params[:shipment][:tracking_numbers_attributes].each do |tracking|
      unless tracking[1]["number"].blank?
        shipment.tracking_numbers.new(:number => tracking[1]["number"])
      end
    end
    
    if shipment.save
      ShipmentMailer.shipment_confirmation(shipment.id).deliver_later
      redirect_to order_path(params[:order_id])
    else
      redirect_to :back
    end
  end
  
  def shipment_params
    # params.dig(:shipment, :tracking_numbers_attributes)
      # next unless v[:number].to_s.empty?
      # params[:shipment][:tracking_numbers_attributes].delete(k)
    # end
    params.require(:shipment)
          .permit(:date, :ship_date, :carrier, :order_id, tracking_numbers_attributes: [:number],
                  line_item_shipments_attributes: [:order_line_item_id, :bin_id, :quantity_shipped])
  end

end