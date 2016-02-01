class Order < ActiveRecord::Base
  
  include ApplicationHelper
  
  has_many :order_line_items
  has_many :order_shipping_methods
  belongs_to :account
  has_many :items, :through => :order_line_items
  
  accepts_nested_attributes_for :order_line_items, :allow_destroy => true
  
  before_save :make_record_number
  # before_save :make_total
  
  def sub_total
    total = 0
    order_line_items.each {|ol| total += ol.sub_total}
    total
  end
  
  def shipping_total
    total = 0
    order_shipping_methods.each {|os| total += os.amount}
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
