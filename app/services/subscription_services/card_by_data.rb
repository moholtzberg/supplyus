module SubscriptionServices
  class CardByData
    def call(card_hash, subscription, card_token)
      if subscription.payment_method == 'check'
        return nil
      elsif !card_token.empty?
        CreditCard.find_by(account_payment_service_id: subscription.account.main_service.id, service_card_id: card_token)
      else
        CreditCard.store({
          cardholder_name: card_hash[:cardholder_name],
          number: card_hash[:number],
          cvv: card_hash[:cvv],
          expiration_month: card_hash[:expiration_month],
          expiration_year: card_hash[:expiration_year],
          customer_id: subscription.account.main_service.service_id,
          account_payment_service_id: subscription.account.main_service.id
        })
      end
    end
  end
end