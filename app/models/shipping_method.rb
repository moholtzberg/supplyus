class ShippingMethod < ActiveRecord::Base
  
  belongs_to :shipping_calculater
  
  def calculate(order_amount)
    rate * order_amount
  end
  
end