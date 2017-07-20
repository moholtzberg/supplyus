module SubscriptionServices
  class CardByData
    def call(card_hash, subscription, card_token)
      if subscription.payment_method != 'credit_card'
        return nil
      elsif card_token
        CreditCard.find_by(account_payment_service_id: subscription.account.main_service.id, service_card_id: card_token)
      else
        CreditCard.store({
          cardholder_name: params[:cardholder_name],
          number: params[:credit_card_number],
          cvv: params[:card_security_code],
          expiration_month: params[:expiration_month],
          expiration_year: params[:expiration_year],
          customer_id: subscription.account.main_service.service_id,
          account_payment_service_id: subscription.account.main_service.id
        })
      end
    end
  end
end