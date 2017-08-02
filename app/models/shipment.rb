class Shipment < ActiveRecord::Base
  
  has_many :line_item_shipments, dependent: :destroy
  has_many :order_line_items, -> { distinct }, :through => :line_item_shipments
  has_many :orders, :through => :order_line_items
  has_many :tracking_numbers, dependent: :destroy

  accepts_nested_attributes_for :line_item_shipments
  accepts_nested_attributes_for :tracking_numbers
  
end