class LineItemShipment < ActiveRecord::Base
  
  belongs_to :order_line_item
  belongs_to :shipment
  
end