class Charge < ActiveRecord::Base
  
  scope :unbilled, -> { where(:invoice => nil) }
  scope :billed, -> { where(:invoice => !nil) }
  scope :by_account, -> (account_id) { where(:account_id => account_id) }
  scope :by_plan, -> (plan_id) { where(:payment_plan_id => plan_id) }
  scope :by_invoice, -> (invoice_id) { where(:inovice_id => invoice_id) }
  scope :by_billed_through, -> { order(:to_date => :desc) }
  
  belongs_to :invoice
  belongs_to :account
  belongs_to :payment_plan
  
  before_save :ensure_account_present
  before_save :ensure_amount
  before_save :ensure_quantity
  
  # validates :amount, :presence => true
  
  # before_create :make_line_number, :on => :create
  # 
  # validates :line_number, :uniqueness => {
  #   :scope => :invoice_id
  # }
  
  def ensure_account_present
    if self.account_id.nil? && !self.payment_plan_id.nil?
      self.account_id = self.payment_plan.account_id
    end
  end
  
  def ensure_amount
    puts "self.amount >>>>>>>>>>>>>>>>>>>>>>>>>>>>> #{self.amount}"
    if self.amount.nil?
      self.amount = 0.0
    end
  end
  
  def ensure_quantity
    puts "self.quantity >>>>>>>>>>>>>>>>>>>>>>>>>>>>> #{self.quantity}"
    if self.quantity.nil?
      self.quantity = 1
    end
  end
  
  def sub_total
    self.quantity.to_f * self.amount.to_f
  end
  
  # def make_line_number
  #   if self.invoice_id.blank?
  #     puts "NO INVOICE YETTTTTTTTTTTTTTTTTTTTTTTTTTTTTT"
  #   else
  #     self.line_number = self.invoice.charges.count + 1
  #   end
  # end
  
end