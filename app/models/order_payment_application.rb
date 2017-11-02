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
    return if payment.amount.to_d >= [total_applied_on_payment, applied_amount.to_d].sum.to_d
    errors.add(:amount, "Can't over apply payment, #{total_applied_on_payment}"\
               " is greater than the payment amount of #{payment.amount}")
  end

  def order_has_balance
    return if order.balance_due.to_d >= applied_amount.to_d
    errors.add(:amount, "Can't over apply payment amount greater than balance"\
               " due on order, #{applied_amount} is greater than the amount"\
               " of the balance due on the order #{order.balance_due}")
  end
end
