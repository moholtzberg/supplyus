class CreditCard < ActiveRecord::Base

  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :card_security_code
  attr_accessor :credit_card_number
  attr_accessor :expiration_month
  attr_accessor :expiration_year
    
  belongs_to :account_payment_service
  has_many :credit_card_payments

  scope :expiring_soon, -> { where(expiration: 30.days.ago..90.days.from_now) }
  scope :active, -> { where("expiration >= ?", Date.today) }
  # before_save :charge_card
    
  # def charge_card
  #   if Stripe::Charge.create(:amount => (self.amount.to_i * 100), :currency => "usd", :customer => PaymentPlan.find(self.payment_plan).account.stripe_customer_id)
  #     # .last_billing_date = Date.today
  #     PaymentPlan.update(self.payment_plan, :last_billing_date => Date.today).save!
  #   end
  # end

  def active_merchant_card
    ActiveMerchant::Billing::CreditCard.new(
      number:              credit_card_number,
      verification_value:  card_security_code,
      month:               expiration_month,
      year:                expiration_year,
      first_name:          first_name,
      last_name:           last_name
    )
  end

  def store
    response = GATEWAY.store(active_merchant_card, options: {customer: account_payment_service.service_id})
    if response.success?
      self.service_card_id = response.params['credit_card_token']
      self.expiration = "#{expiration_month}/#{expiration_year}"
      self.last_4 = credit_card_number[-4..-1]
      self.card_type = response.params['braintree_customer']['credit_cards'].select { |card| card['token'] == self.service_card_id }.first['card_type']
    end
    response.success?
  end

  def logo_class
    case card_type
    when 'Visa'
      'fa fa-cc-visa'
    when 'MasterCard'
      'fa fa-cc-mastercard'
    when 'JCB'
      'fa fa-cc-jcb'
    when 'Discover'
      'fa fa-cc-discover'
    when 'Diners Club'
      'fa fa-cc-diners-club'
    when 'American Express'
      'fa fa-cc-amex'
    else
      'fa fa-credit-card'
    end
  end
end
