class CreditCardPayment < Payment
  require 'active_merchant/billing/rails'

  validates :amount, :presence => true, :numericality => { greater_then: 0 }
  belongs_to :credit_card
  
  def authorize
    if credit_card_id
      response = GATEWAY.authorize(amount * 100, credit_card.service_card_id, {payment_method_token: true})

      if response.authorization and response.success?
        self.authorization_code = response.authorization
        self.success = response.success?
        true
      else
        errors.add(:base, "The credit card you provided was declined. Please double check your information and try again.") and return
        false
      end
      
    else
      errors.add(:base, "The credit card you provided was declined. Please double check your information and try again.") and return
      false
    end
  end
  
  def capture
    if credit_card_id && authorization_code
      transaction = GATEWAY.capture(amount * 100, authorization_code)
      if !transaction.success?
        errors.add(:base, "The credit card you provided was declined.  Please double check your information and try again.") and return
        false
      end
      update_columns({authorization_code: transaction.authorization, success: true})
      true
    end
  end
  
  def process
    if credit_card_id
      response = GATEWAY.authorize(amount * 100, credit_card.service_card_id, {payment_method_token: true})
      if response.success?
        transaction = GATEWAY.capture(amount * 100, response.authorization)
        if !transaction.success?
          errors.add(:base, "The credit card you provided was declined.  Please double check your information and try again.") and return
          false
        end
        update_columns({authorization_code: transaction.authorization, success: true})
        true
      else
        errors.add(:base, "The credit card you provided was declined.  Please double check your information and try again.") and return
        false
      end
    end
  end

end