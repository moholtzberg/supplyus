class PurchaseOrderReceipt < ActiveRecord::Base
  
  belongs_to :purchase_order
  has_many :purchase_order_line_item_receipts, dependent: :destroy
  has_many :purchase_order_line_items, :through => :purchase_order_line_item_receipts
  # has_many :orders, :through => :order_line_items
  # has_many :tracking_numbers
  accepts_nested_attributes_for :purchase_order_line_item_receipts
  
end