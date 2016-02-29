class ShippingCalculator < ActiveRecord::Base
  
  has_many :shipping_methods
  
end