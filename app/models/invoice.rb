class Invoice < ActiveRecord::Base
  include ApplicationHelper
  
  has_many :line_item_fulfillments
  has_many :order_line_items, :through => :line_item_fulfillments
  has_many :charges
  has_many :invoice_payment_applications
  has_many :payments, :through => :invoice_payment_applications
  belongs_to :account
  belongs_to :payment_plan
  scope :by_account, -> (account_id) { where(:account_id => account_id) }
  
  accepts_nested_attributes_for :charges, :allow_destroy => true
  validates_associated :charges
  
  before_save :make_record_number
  
  after_save :update_total
  
  def update_total
    puts "---------> updating total"
    if self.sum == 0
      return false
    else
      prepare_charges_for_billing
    end
    self.total = sum
  end
  
  def prepare_charges_for_billing
    puts "---------> account => #{self.account_id}"
    charges = self.account.charges.unbilled
    puts "---------> charges => #{self.account.charges.unbilled.inspect}"
    invoice_id = self.id
    puts self.inspect
    charges.each do |charge|
      # puts "---------->> charge => #{b.inspect}"
      # a = Charge.find(b.id)
      # puts "----X #{b.id}"
      # a.invoice_id = b.id
      # puts "----V #{a.invoice}"
      # a.save
      charge.invoice_id = invoice_id
      puts "----M #{charge.inspect}"
      charge.save!
    end
  end
  
  def sub_total
    total = 0
    order_line_items.find_each {|ol| total += ol.sub_total}
    total
  end
  
  
  def sum
    puts "---------> getting sum of all charges.inspect"
    a = self.charges.map {|c| c.amount }
    return a.sum.to_f
  end
  
  def make_subtotal
    self.sub_total = 0.0
    self.order_lines.each {|q| self.sub_total = (self.sub_total.to_f + q.sub_total.to_f) }
  end
  
  def make_total
    make_subtotal
    self.total = (self.sub_total.to_f - self.discount.to_f + self.freight.to_f + self.tax.to_f)
  end
  
  def paid
    total_paid = 0.0
    self.payments.each {|a| total_paid = total_paid + a.amount}
    total_paid == self.sum ? true : false
  end
  
  def balance_due
    total_paid = 0.0
    puts self.payments.count
    self.payments.each {|a| total_paid = total_paid + a.amount}
    return (self.sum.to_f - total_paid.to_f)
  end
  
end