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

  def self.store(params)
    if GATEWAY.class == ActiveMerchant::Billing::BraintreeBlueGateway
      resp = Braintree::CreditCard.create(
        customer_id: params[:customer_id],
        cardholder_name: params[:cardholder_name],
        number: params[:number],
        cvv: params[:cvv],
        expiration_month: params[:expiration_month],
        expiration_year: params[:expiration_year],
        options: { fail_on_duplicate_payment_method: true }
      )
      if resp.class == Braintree::SuccessfulResult
        self.create(
          account_payment_service_id: params[:account_payment_service_id],
          service_card_id: resp.credit_card.token,
          expiration: "#{params[:expiration_month]}/#{params[:expiration_year]}",
          last_4: resp.credit_card.last_4,
          card_type: resp.credit_card.card_type
        )
      elsif resp.class == Braintree::ErrorResult && resp.errors.select{ |error| error.code == '81724' }.size > 0 && resp.errors.size == 1
        self.find_by(
            account_payment_service_id: params[:account_payment_service_id],
            expiration: "#{params[:expiration_month]}/#{params[:expiration_year]}",
            last_4: params[:number][-4..-1]
          )
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
