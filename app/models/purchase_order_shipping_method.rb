class PurchaseOrderShippingMethod < ActiveRecord::Base
  
  belongs_to :purchase_order, :touch => true
  belongs_to :shipping_method
  
  validates :purchase_order, :uniqueness => true
  
  delegate :name, :to => :shipping_method
  
end