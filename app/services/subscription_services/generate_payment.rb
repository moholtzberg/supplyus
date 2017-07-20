module SubscriptionServices
  class GeneratePayment
    def call(order, card = nil)
      if order
        payment = order.payments.new
        payment.account = order.account
        payment.amount = order.total
        if card
          payment.payment_type = "CreditCard"
          payment.credit_card_id = card.id
        else
          payment.payment_type = "CheckPayment"
        end
        payment
      end
    end
  end
end