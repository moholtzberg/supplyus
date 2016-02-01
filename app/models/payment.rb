class Payment < ActiveRecord::Base
  
  has_and_belongs_to_many :invoices
  belongs_to :account
  belongs_to :payment_method
  belongs_to :credit_card
  
end