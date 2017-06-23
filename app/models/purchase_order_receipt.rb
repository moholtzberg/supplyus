class PurchaseOrderReceipt < ActiveRecord::Base
  
  has_many :purchase_order_line_item_receipts
  has_many :purchase_order_line_items, :through => :purchase_order_line_item_receipts
  # has_many :orders, :through => :order_line_items
  # has_many :tracking_numbers
  accepts_nested_attributes_for :purchase_order_line_item_receipts
  
end