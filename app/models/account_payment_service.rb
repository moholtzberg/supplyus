class AccountPaymentService < ActiveRecord::Base

  PROVIDERS_HASH = {'ActiveMerchant::Billing::BraintreeBlueGateway' => 'braintree'}
  
  belongs_to :account

  has_many :credit_cards
  
  validates :account_id, presence: true
  validates :name, presence: true, inclusion: ['braintree', 'test'], uniqueness: {scope: :account_id}
  validates :service_id, presence: true

  def self.lookup(term)
    joins(:account).where("lower(accounts.name) like (?) or lower(account_payment_services.service_id) like (?) or lower(account_payment_services.name) like (?)", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%")
  end

  def account_name
    account.try(:name)
  end
  
  def account_name=(name)
    self.account = Account.find_by(:name => name) if name.present?
  end
  
end
