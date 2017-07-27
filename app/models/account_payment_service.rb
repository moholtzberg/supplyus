class AccountPaymentService < ActiveRecord::Base

  PROVIDERS_HASH = {'ActiveMerchant::Billing::BraintreeBlueGateway' => 'braintree'}
  
  belongs_to :account

  has_many :credit_cards
  
  validates :account_id, presence: true
  validates :name, presence: true, inclusion: ['braintree'], uniqueness: {scope: :account_id}
  validates :service_id, presence: true
  
end
