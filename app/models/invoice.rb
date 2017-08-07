class Invoice < ActiveRecord::Base
  include ApplicationHelper
  
  has_many :line_item_fulfillments, dependent: :destroy
  has_many :order_line_items, :through => :line_item_fulfillments
  belongs_to :order
  has_many :charges
  has_many :invoice_payment_applications
  has_many :payments, :through => :invoice_payment_applications
  belongs_to :account
  belongs_to :payment_plan
  scope :by_account, -> (account_id) { where(:account_id => account_id) }
  
  delegate :ship_to_account_name, :ship_to_attention, :ship_to_address_1, :ship_to_address_2, :ship_to_city, :ship_to_state, :ship_to_zip, :ship_to_phone, :ship_to_email, :ship_to_fax, :to => :order
  delegate :bill_to_account_name, :bill_to_attention, :bill_to_address_1, :bill_to_address_2, :bill_to_city, :bill_to_state, :bill_to_zip, :bill_to_phone, :bill_to_email, :bill_to_fax, :to => :order
  delegate :po_number, :order_shipping_method, :shipping_total, :to => :order
  
  accepts_nested_attributes_for :charges, :allow_destroy => true
  validates_associated :charges
  
  before_save :make_record_number
  
  after_save :update_total
  after_save :confirm_order_fulfillment
  
  def self.by_order(order_id)
    includes(:order_line_items).where(:order_line_items => {:order_id => order_id}).references(:order_line_items)
  end
  
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
  
  def total
    sub_total + shipping_total
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
  
  def payments_total
    total_paid = 0.0
    self.payments.each {|a| total_paid = total_paid + a.amount}
    total_paid
  end
  
  def paid
    total_paid = 0.0
    self.payments.each {|a| total_paid = total_paid + a.amount}
    total_paid == self.total ? true : false
  end
  
  def balance_due
    total_paid = 0.0
    puts self.payments.count
    self.payments.each {|a| total_paid = total_paid + a.amount}
    return (self.total.to_f - total_paid.to_f)
  end
  
  def due_on
    if self.due_date
      self.due_date
    else
      if account.payment_terms
        self.date + account.payment_terms
      else
        self.date + 30.days
      end
    end
  end

  def confirm_order_fulfillment
    order.confirm_fulfillment
  end
  
end