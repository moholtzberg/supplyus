class Payment < ActiveRecord::Base
  
  # has_and_belongs_to_many :invoices
  belongs_to :account
  belongs_to :payment_method
  has_one :order_payment_application
  has_many :transactions
  accepts_nested_attributes_for :order_payment_application
  
end