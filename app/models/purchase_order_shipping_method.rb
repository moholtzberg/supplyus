class PurchaseOrderShippingMethod < ActiveRecord::Base
  
  belongs_to :purchase_order, :touch => true, :inverse_of => :purchase_order_shipping_method
  belongs_to :shipping_method
  
  validates :purchase_order, :uniqueness => true, :presence => true
  validates :shipping_method, :presence => true
  
  delegate :name, :to => :shipping_method
  
end