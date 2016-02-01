class PaymentPlan < ActiveRecord::Base
  
  belongs_to :account
  belongs_to :payment_plan_template
  has_many :reciepts
  has_many :charges
  has_many :invocies
  
  scope :active, -> { where(billing_end: nil) }
  scope :new_plan, -> { where(last_billing_date: nil) }
  scope :starts_today, -> { where(:billing_start => Date.today) }
  # scope :bill_date_passed, lambda { puts "-->>>>> #{self.active?}"}
  
  default_scope { order({billing_start: :asc}, {last_billing_date: :asc}, {amount: :asc}) }
  
  after_create :bill_first_cycle
  
  def billed_through
    if !self.charges.by_billed_through.last.nil?
      self.charges.by_billed_through.last.to_date
    else
      # self.billing_start
      nil
    end
    
  end
  
  def last_billed_date
    if !self.charges.by_billed_through.last.nil?
      self.charges.by_billed_through.last.from_date
    else
      # self.billing_start
      nil
    end
  end
  
  def bill_first_cycle
    if self.active? && self.new_plan?
      days_left = (self.billing_start.end_of_month.next_day - self.billing_start)
      daily_rate = (self.amount / self.billing_start.end_of_month.day)
      amount_to_charge = (daily_rate * days_left)
      # stripe = Stripe::Customer.retrieve(self.account.stripe_customer_id)
      Charge.create(amount: amount_to_charge, payment_plan_id: self.id, from_date: self.billing_start, to_date: self.billing_start.end_of_month, description: "#{self.name} - #{self.billing_start.month} - Prorated")
    end
  end
  
  def active?
    return self.billing_end.nil? ? true : false
  end
  
  def new_plan?
    # return self.last_billing_date.nil? ? true : false
    return self.billed_through.nil? ? true : false
  end
  
  def next_bill_date
    if self.new_plan?
      self.billing_start
    else
      # self.last_billing_date.end_of_month.next_day
      self.billed_through.end_of_month.next_day
    end
  end
  
  def self.bill_date_passed
    PaymentPlan.active.all.select { |p| p.next_bill_date <= Date.today }
  end
  
end