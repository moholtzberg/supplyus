class Account < ActiveRecord::Base
  
  # self.inheritance_column = :account_type
  # 
  # scope :customers, -> { where(:account_type => "Customer")}
  # scope :vendors, -> { where(:account_type => "Vendor")}
  # 
  # def self.account_types
  #   %w(Customer Vendor)
  # end
  
  has_many :users
  has_many :contacts
  has_many :equipment, :class_name => "Equipment"
  has_many :charges
  has_many :receipts
  has_many :payment_plans
  has_many :invoices
  has_many :credit_cards
  has_many :orders
  
  validates :name, :presence => true
  validates :address_1, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true
  validates :zip, :presence => true
  # before_create :set_billing_start_and_day
  # after_create  :set_up_payment_plans
  
  # Billing days range from 1-28
  # def set_billing_start_and_day
  #   date = Date.today + self.demo_period.to_i
  #   self.billing_start ||= date
  #   self.billing_day   ||= [date.day, 28].min
  # end

  # def set_up_payment_plans
  #   self.payment_plans = PaymentPlanTemplate.all.map(&:to_plan)
  # end
  
  # def billing_period(date)
  #   billing_period_start_date_for(date)..billing_period_end_date_for(date)
  # end

  # def billing_period_start_date_for(date)
  #     year, month = if date.day < billing_day
  #       [(date - 1.month).year, (date - 1.month).month]
  #     else
  #       [date.year, date.month]
  #     end
  #     
  #     Date.new(year, month, billing_day)
  #   end
  
  #   def billing_period_end_date_for(date)
  #     year, month = if date.day < billing_day
  #       [date.year, date.month]
  #     else
  #       [(date + 1.month).year, (date + 1.month).month]
  #     end
  #     
  #     Date.new(year, month, billing_day) - 1.day
  #   end
  
end