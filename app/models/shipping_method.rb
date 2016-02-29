class ShippingMethod < ActiveRecord::Base
  
  belongs_to :shipping_calculator
  
  def calculate(order_amount)
    calculation = self.shipping_calculator.calculation_method
    puts "------> #{calculation}"
    if calculation == "flat"
      amount = (rate.to_f >= self.minimum_amount.to_f) ? rate.to_f : self.minimum_amount.to_f
      puts "1-------> #{amount}"
      amount = determine_free_shipping(amount)
      puts "2-------> #{amount}"
      amount.to_f
    elsif calculation == "percentage"
      amount = (rate/100) * order_amount
      puts "1-------> #{amount}"
      amount = (rate.to_f >= self.minimum_amount.to_f) ? rate.to_f : self.minimum_amount.to_f
      puts "2-------> #{amount}"
      amount = determine_free_shipping(amount)
      puts "3-------> #{amount}"
      amount.to_f
    end
    
  end
  
  def determine_free_shipping(amount)
    puts "XXX-------> #{amount}"
    if self.free_at_amount.to_f < amount.to_f
      puts "-------> #{self.free_at_amount}  =>  #{amount}"
      0
    else
      amount.to_f
    end
  end
  
end