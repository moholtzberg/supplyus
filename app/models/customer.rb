class Customer < Account
  
  self.inheritance_column = 'account_type'
  
  belongs_to :user
  # has_many :contacts
  has_many :equipment, :class_name => "Equipment"
  # has_many :charges
  # has_many :receipts
  # has_many :payment_plans
  # has_many :invoices
  # has_many :credit_cards
  has_many :orders, :foreign_key => :account_id
  
  
  def payment_terms
    90
  end
  
end