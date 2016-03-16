class LineItemShipment < ActiveRecord::Base
  
  belongs_to :order_line_item, :touch => true
  belongs_to :shipment, :touch => true
  
end