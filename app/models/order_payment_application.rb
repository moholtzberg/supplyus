class OrderPaymentApplication < ActiveRecord::Base
  
  belongs_to :order
  belongs_to :payment
  belongs_to :credit_card_payment
  
end