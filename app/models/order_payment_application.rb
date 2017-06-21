class OrderPaymentApplication < ActiveRecord::Base
  
  belongs_to :order
  belongs_to :payment
  belongs_to :credit_card_payment
  
  validate :not_over_applying
  validate :order_has_balance
  
  
  def total_applied_on_payment
    payment.applied_amount.to_d
  end
  
  def not_over_applying
    puts "TA -------> #{total_applied_on_payment}"
    puts "PA -------> #{payment.amount}"
    if payment.amount.to_d < [total_applied_on_payment.to_d, applied_amount.to_d].sum.to_d
      errors.add("Can't over apply payment, #{total_applied_on_payment} is grater than the payment amount of #{payment.amount}")
      false
    else
      true
    end
  end
  
  def order_has_balance
    if order.balance_due.to_d < applied_amount.to_d
      errors.add("Can't over apply payment amount greater than balance due on order, #{applied_amount} is grater than the amount of the balance due on the order #{order.balance_due}")
      false
    end
  end
  
end