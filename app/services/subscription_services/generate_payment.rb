module SubscriptionServices
  class GeneratePayment
    def call(order, subscription, card = nil)
      if order
        payment = order.payments.new
        payment.account = order.account
        payment.amount = order.order_line_items.inject(0) { |mem, var| mem += var.price * var.quantity  }
        payment.payment_method = PaymentMethod.find_or_create_by(name: subscription.payment_method, active: true)
        if card
          payment.payment_type = "CreditCardPayment"
          payment.credit_card_id = card.id
        else
          payment.payment_type = "CheckPayment"
        end
        payment.becomes payment.payment_type.constantize
      end
    end
  end
end