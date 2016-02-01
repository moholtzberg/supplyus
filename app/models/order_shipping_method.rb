class OrderShippingMethod < ActiveRecord::Base
  
  belongs_to :order
  belongs_to :shipping_method
  
  validates :order, :uniqueness => true
  
  delegate :name, :to => :shipping_method
  
end