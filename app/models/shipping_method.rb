class ShippingMethod < ActiveRecord::Base
  
  belongs_to :shipping_calculator
  
  def calculate(order_amount)
    calculation = self.shipping_calculator.calculation_method
    puts "------> #{calculation}"
    if calculation.downcase == "flat"
      shipping_amount = (rate.to_f >= self.minimum_amount.to_f) ? rate.to_f : self.minimum_amount.to_f
      puts "1-------> #{shipping_amount}"
      amount = determine_free_shipping(order_amount, shipping_amount)
      puts "2-------> #{amount}"
      amount.to_f
    elsif calculation.downcase == "percentage"
      shipping_amount = (rate/100) * order_amount
      puts "1-------> #{amount}"
      shipping_amount = (shipping_amount.to_f >= self.minimum_amount.to_f) ? shipping_amount.to_f : self.minimum_amount.to_f
      puts "2-------> #{amount}"
      amount = determine_free_shipping(order_amount, shipping_amount)
      puts "3-------> #{amount}"
      amount.to_f
    end
  end
  
  def determine_free_shipping(order_amount, shipping_amount)
    puts "Order Amount-------> #{order_amount}"
    puts "Shipping Amount-------> #{shipping_amount}"
    if self.free_at_amount.to_f < order_amount.to_f
      puts "-------> #{self.free_at_amount}  =>  #{order_amount}"
      0
    else
      shipping_amount.to_f
    end
  end
  
  def shipping_calculator_name
    shipping_calculator.try(:name)
  end
  
  def shipping_calculator_name=(name)
    self.shipping_calculator = ShippingCalculator.find_by(:name => name) if name.present?
  end
  
end