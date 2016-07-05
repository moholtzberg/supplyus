class Account < ActiveRecord::Base
  devise :registerable
  self.inheritance_column = :account_type
  
  alias_attribute :address_1, :ship_to_address_1
  alias_attribute :address_2, :ship_to_address_2
  alias_attribute :city,      :ship_to_city
  alias_attribute :state,     :ship_to_state
  alias_attribute :zip,       :ship_to_zip
  alias_attribute :phone,     :ship_to_phone
  alias_attribute :fax,       :ship_to_fax
  
  def bill_address_1
    ship_to_address_1 if bill_to_address_1.blank?
  end
  
  def bill_address_2
    ship_to_address_2 if bill_to_address_2.blank?
  end
  
  def bill_city
    ship_to_city if bill_to_city.blank?
  end
  
  def bill_state
    ship_to_state if bill_to_state.blank?
  end
  
  def bill_zip
    ship_to_zip if bill_to_zip.blank?
  end
  # scope :customers, -> { where(:account_type => "Customer")}
  # scope :vendors, -> { where(:account_type => "Vendor")}
  # 
  # def self.account_types
  #   %w(Customer Vendor)
  # end
  
  def self.lookup(term)
    includes(:user).where("lower(users.first_name) like (?) or lower(users.last_name) like (?) or lower(users.email) like (?) or lower(accounts.name) like (?)", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%").references(:user)
  end
  
  belongs_to :user
  belongs_to :group
  has_many :contacts
  has_many :equipment, :class_name => "Equipment"
  has_many :charges
  has_many :receipts
  has_many :payment_plans
  has_many :invoices
  has_many :credit_cards
  has_many :orders
  has_many :order_line_items, :through => :orders
  has_many :account_item_prices
  #   
  validates :name, :presence => true
  validates :ship_to_address_1, :presence => true
  validates :ship_to_city, :presence => true
  validates :ship_to_state, :presence => true
  validates :ship_to_zip, :presence => true
  
  def has_credit
    if credit_limit > 0 and credit_hold != true and credit_terms > 1
      true
    else
      false
    end
  end
  
  def payment_terms
    90
  end
  
  def self.search(term)
    where("lower(name) like (?)", "%#{term.downcase}%")
  end
  
  def group_name
    group.try(:name)
  end
  
  def group_name=(name)
    self.group = Group.find_by(:name => name) if name.present?
  end
  
  def outstanding_invoices
    orders.fulfilled.unpaid.map(&:total).sum
  end
  
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