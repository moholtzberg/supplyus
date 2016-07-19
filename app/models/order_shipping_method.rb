class OrderShippingMethod < ActiveRecord::Base
  
  belongs_to :order, :touch => true
  belongs_to :shipping_method
  
  validates :order, :uniqueness => true
  
  delegate :name, :to => :shipping_method
  
end