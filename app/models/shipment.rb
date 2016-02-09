class Shipment < ActiveRecord::Base
  
  has_many :line_item_shipments
  has_many :order_line_items, :through => :line_item_shipments
  has_many :orders, :through => :order_line_items
  has_many :tracking_numbers
  
end