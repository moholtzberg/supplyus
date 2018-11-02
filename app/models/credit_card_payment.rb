class CreditCardPayment < Payment
  require 'active_merchant/billing/rails'

  belongs_to :credit_card

  def authorize
    puts "here"
    if credit_card_id
      response = GATEWAY.authorize(amount * 100, credit_card.service_card_id, {payment_method_token: true})

      if response.authorization and response.success?
        self.authorization_code = response.authorization
        true
      else
        errors.add(:base, "1 The credit card you provided was declined. Please double check your information and try again.") and return
        false
      end
      
    else
      errors.add(:base, "2 The credit card you provided was declined. Please double check your information and try again.") and return
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
      update_columns({authorization_code: transaction.authorization, success: true, captured: true})
      true
    else
      errors.add(:base, "Payment is not authorized or credit card is missing.") and return
      false
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
        update_columns({authorization_code: transaction.authorization, success: true, captured: true})
        true
      else
        errors.add(:base, "The credit card you provided was declined.  Please double check your information and try again.") and return
        false
      end
    end
  end

  def refund(sum)
    return false unless credit_card_id && captured
    response = GATEWAY.refund(sum * 100, authorization_code)
    if response.success?
      update_columns(refunded: sum)
    else
      errors.add(:base, 'refund failed.') && return
      false
    end
  end

  def authorized?
    authorization_code
  end
end
