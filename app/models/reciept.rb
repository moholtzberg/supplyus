class Reciept < ActiveRecord::Base
    # composed_of :amount, class_name: 'Money::Millicents', mapping: [:amount, :value], converter: :new
    belongs_to :payment_plan
    
    before_save :charge_card
    
    def charge_card
      if Stripe::Charge.create(:amount => (self.amount.to_i * 100), :currency => "usd", :customer => PaymentPlan.find(self.payment_plan).account.stripe_customer_id)
        # .last_billing_date = Date.today
        PaymentPlan.update(self.payment_plan, :last_billing_date => Date.today).save!
      end
    end
end

# class Money::Millicents < SimpleDelegator
#   include Comparable
# 
#   def initialize(value = 0)
#     super(value.to_i)
#   end
# 
#   def to_euros
#     (__getobj__ / 1000.0).ceil / 100.0
#   end
# end