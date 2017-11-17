class CreditCard < ActiveRecord::Base

  attr_accessor :card_security_code
  attr_accessor :credit_card_number
  attr_accessor :expiration_month
  attr_accessor :expiration_year

  belongs_to :account_payment_service
  has_many :credit_card_payments
  has_many :subscriptions

  validates_presence_of :cardholder_name, :account_payment_service_id, :service_card_id, :expiration, :last_4, :card_type

  before_validation :store_gateway, on: :create
  before_validation :update_gateway, on: :update
  before_validation :remove_gateway, on: :destroy
  after_update :check_failed_subscription_payments

  scope :expiring_soon, -> { where(expiration: 30.days.ago..90.days.from_now) }
  scope :active, -> { where("expiration >= ?", Date.today) }
  # before_save :charge_card
    
  # def charge_card
  #   if Stripe::Charge.create(:amount => (self.amount.to_i * 100), :currency => "usd", :customer => PaymentPlan.find(self.payment_plan).account.stripe_customer_id)
  #     # .last_billing_date = Date.today
  #     PaymentPlan.update(self.payment_plan, :last_billing_date => Date.today).save!
  #   end
  # end

  def self.lookup(term)
    includes(account_payment_service: :account).where('lower(accounts.name) like (?) or lower(credit_cards.cardholder_name) like (?)'\
      ' or lower(credit_cards.last_4) like (?) or lower(credit_cards.service_card_id) like (?)',
     "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%").references(:account)
  end

  def store_gateway
    if GATEWAY.class == ActiveMerchant::Billing::BraintreeBlueGateway
      if account_payment_service
        unique_numbers = account_payment_service&.credit_cards&.map(&:unique_number_identifier)
        resp = Braintree::CreditCard.create(
          customer_id: account_payment_service&.service_id,
          cardholder_name: cardholder_name,
          number: credit_card_number,
          cvv: card_security_code,
          expiration_month: expiration_month,
          expiration_year: expiration_year
        )
        if resp.class == Braintree::SuccessfulResult
          if unique_numbers.include?(resp.credit_card.unique_number_identifier)
            Braintree::CreditCard.delete(resp.credit_card.token)
            errors.add(:base, 'Same card exists for this user.')
          else
            self.assign_attributes(
              unique_number_identifier: resp.credit_card.unique_number_identifier,
              service_card_id: resp.credit_card.token,
              expiration: "#{expiration_month}/#{expiration_year}",
              last_4: resp.credit_card.last_4,
              card_type: resp.credit_card.card_type
            )
          end
        else
          errors.add(:base, resp.errors.map(&:message).join(' '))
        end
      else
        errors.add(:base, 'Account is not set.')
      end
    end
    errors.empty?
  end

  def update_gateway
    if GATEWAY.class == ActiveMerchant::Billing::BraintreeBlueGateway
      resp = Braintree::CreditCard.update(self.service_card_id,
        {
          cardholder_name: cardholder_name,
          expiration_month: expiration.try(:split, '/').try(:[], 0),
          expiration_year: expiration.try(:split, '/').try(:[], 1)
        }
      )
      errors.add(:base, resp.errors.map(&:message).join(' ')) if resp.class != Braintree::SuccessfulResult
    end
    errors.empty?
  end

  def remove_gateway
    response = GATEWAY.unstore(nil, {credit_card_token: self.service_card_id})
    response.success?
  end

  def check_failed_subscription_payments
    self.subscriptions.each do |subscription|
      subscription.orders.where(state: 'hold').each do |order|
        order.payments.where(success: false).each do |payment|
          if payment.authorize
            order.resume
          else
            OrderMailer.order_failed_authorization(order.id).deliver_later
            SubscriptionMailer.update_cc(self).devliver_later
          end
        end
      end
    end
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
