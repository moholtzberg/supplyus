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
    shipment = Shipment.new(shipment_params.merge(date: Time.now))
    if shipment.save
      ShipmentMailer.shipment_confirmation(shipment.id).deliver_later
      redirect_to order_path(params[:order_id])
    else
      redirect_to :back
    end
  end

  def shipment_params
    params.dig(:shipment, :tracking_numbers_attributes).each do |k, v|
      next unless v[:number].to_s.empty?
      params[:shipment][:tracking_numbers_attributes].delete(k)
    end
    params.require(:shipment)
          .permit(:date, :ship_date, :carrier, :order_id, tracking_numbers_attributes: [:number],
                  line_item_shipments_attributes: [:order_line_item_id, :bin_id, :quantity_shipped])
  end
end
