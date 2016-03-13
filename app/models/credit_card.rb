class CreditCard < ActiveRecord::Base
    
    belongs_to :account
    belongs_to :payment_plan
    
    scope :expiring_soon, -> { where(expiration: 30.days.ago..90.days.from_now) }
    scope :active, -> { where("expiration >= ?", Date.today) }
    # before_save :charge_card
    
    # def charge_card
    #   if Stripe::Charge.create(:amount => (self.amount.to_i * 100), :currency => "usd", :customer => PaymentPlan.find(self.payment_plan).account.stripe_customer_id)
    #     # .last_billing_date = Date.today
    #     PaymentPlan.update(self.payment_plan, :last_billing_date => Date.today).save!
    #   end
    # end
end
