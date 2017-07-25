module SubscriptionServices
  class GeneratePayment
    def call(order, card = nil)
      if order
        payment = order.payments.new
        payment.account = order.account
        payment.amount = order.order_line_items.inject(0) { |mem, var| mem += var.price * var.quantity  }
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