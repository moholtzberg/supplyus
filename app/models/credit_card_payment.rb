class CreditCardPayment < Payment
  require 'active_merchant/billing/rails'
  
  attr_accessor :card_security_code
  attr_accessor :credit_card_number
  attr_accessor :expiration_month
  attr_accessor :expiration_year
  
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :card_security_code, :presence => true
  validates :credit_card_number, :presence => true
  validates :expiration_month, :presence => true, :numericality => { greater_then_or_equal_to: 1, less_then_or_equal_to: 12 }
  validates :expiration_year, :presence => true
  validates :amount, :presence => true, :numericality => { greater_then: 0 }
  
  validate :valid_card
  
  def credit_card
    ActiveMerchant::Billing::CreditCard.new(
      number:              credit_card_number,
      verification_value:  card_security_code,
      month:               expiration_month,
      year:                expiration_year,
      first_name:          first_name,
      last_name:           last_name
    )
  end

  def valid_card
    if !credit_card.valid?
      errors.add(:base, "The credit card information you provided is not valid. Please double check the information you provided and then try again.")
      false
    else
      true
    end
  end
  
  def authorize
    if valid_card
      response = GATEWAY.authorize(amount * 100, credit_card)
      
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
    if authorization_code
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
    if valid_card
      response = GATEWAY.authorize(amount * 100, credit_card)
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