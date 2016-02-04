class Order < ActiveRecord::Base
  
  include ApplicationHelper
  
  default_scope { order(:id) }
  #default_scope { self.open }
  
  scope :locked, -> () { where(:locked => true) }
  scope :has_account, -> () { where(:account_id => !nil) }
  scope :no_account, -> () { where(:account_id => !nil) }
  has_many :order_line_items
  has_many :order_shipping_methods, :foreign_key => :order_id
  belongs_to :account
  has_many :items, :through => :order_line_items
  
  accepts_nested_attributes_for :order_line_items, :allow_destroy => true
  
  before_save :make_record_number
  # before_save :make_total
  
  def self.open
    Order.all.select { |o| o.has_line_items }
  end
  
  def self.empty
    Order.all.select { |o| o.has_no_line_items }
  end
  
  def has_line_items
    order_line_items.count >= 1
  end
  
  def has_no_line_items
    order_line_items.count == 0
  end
  
  def sub_total
    total = 0
    order_line_items.find_each {|ol| total += ol.sub_total}
    total
  end
  
  def shipping_total
    total = 0
    order_shipping_methods.find_each {|os| total += os.amount}
    total
  end
  
  def total
    sub_total + shipping_total
  end
  
  # def make_subtotal
  #   self.sub_total = 0.0
  #   self.order_line_items.each {|q| self.sub_total = (self.sub_total.to_f + q.sub_total.to_f) }
  # end
  
  # def make_total
  #   make_subtotal
  #   self.total = (self.sub_total.to_f - self.discount.to_f + self.freight.to_f + self.tax.to_f)
  # end
  
end
