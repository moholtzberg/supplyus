class OrderPaymentApplication < ActiveRecord::Base
  
  belongs_to :order
  belongs_to :payment
  belongs_to :credit_card_payment
  
  validate :not_over_applying
  validate :order_has_balance
  
  def not_over_applying
    total_applied_on_payment = payment.order_payment_applications.map(&:applied_amount).sum
    puts "TA -------> #{total_applied_on_payment}"
    puts "PA -------> #{payment.amount}"
    if payment.amount < total_applied_on_payment
      errors.add("Can't over apply payment, #{total_applied_on_payment} is grater than the payment amount of #{payment.amount}")
      false
    else
      true
    end
  end
  
  def order_has_balance
    if order.balance_due < applied_amount
      errors.add("Can't over apply payment amount greater than balance due on order, #{applied_amount} is grater than the amount of the balance due on the order #{order.balance_due}")
      false
    end
  end
  
end