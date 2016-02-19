class Order < ActiveRecord::Base
  
  include ApplicationHelper
  
  default_scope { order(:id) }
  #default_scope { self.open }
  
  scope :is_locked, -> () { where(:locked => true) }
  scope :is_unlocked, -> () { where.not(:locked => true) }
  scope :is_complete, -> () { where.not(:completed_at => nil)}
  scope :is_incomplete, -> () { where(:completed_at => nil)}
  scope :has_account, -> () { where.not(:account_id => nil) }
  scope :no_account, -> () { where(:account_id => nil) }
  has_many :order_line_items, :dependent => :destroy, :inverse_of => :order
  has_one :order_shipping_method
  belongs_to :account
  has_many :items, :through => :order_line_items
  
  accepts_nested_attributes_for :order_line_items, :allow_destroy => true
  
  before_save :make_record_number
  
  def destroy
    raise "Cannot delete order a locked order" unless locked != true
    raise "Cannot delete an order with shipments" unless quantity_shipped == 0
  end
  
  def self.open
    Order.joins(:order_line_items).distinct(:order_id)
    # Order.all.select { |o| o.has_line_items }
  end
  
  def self.empty
    Order.includes(:order_line_items).where(:order_line_items => {:order_id => nil}).count
    # Order.all.select { |o| o.has_no_line_items }
  end
  
  # def has_line_items
  #     Order.joins(:order_line_items).distinct(:order_id)
  #     # order_line_items.count >= 1
  #   end
  
  # def has_no_line_items
  #   order_line_items.count == 0
  # end
  
  def sub_total
    OrderLineItem.where(order_id: id).group(:order_line_number, :price, :quantity).sum(:price, :quantity).inject(0) {|sum, k| sum + (k[0][1].to_f * k[0][2].to_f)}
    
  end
  
  def shipping_total
    order_shipping_method.amount unless order_shipping_method.nil?
  end
  
  def total
    sub_total.to_f + shipping_total.to_f
  end
  
  def quantity
    # if self.order_line_items
    #   total = 0
    #   self.order_line_items.each {|i| total += i.actual_quantity }
    #   total
    # end
    OrderLineItem.where(order_id: id).group(:order_line_number, :quantity).sum(:quantity).inject(0) {|sum, k| sum + (k[0][1].to_f)}
  end
  
  def shipped
    if self.order_line_items
      total = 0
      self.order_line_items.each {|i| total += i.quantity_shipped }
      total == quantity
    else
      false
    end
  end
  
  def quantity_shipped
    if self.order_line_items
      total = 0
      self.order_line_items.each {|i| total += i.quantity_shipped }
      total
    end
  end
  
  def amount_shipped
    if self.order_line_items
      total = 0
      self.order_line_items.each {|i| total += (i.quantity_shipped.to_f * i.price.to_f) }
      total
    end
  end
  
  def fulfilled
    if self.order_line_items
      total = 0
      self.order_line_items.each {|i| total += i.quantity_fulfilled }
      total == quantity
    else
      false
    end
  end
  
  def quantity_fulfilled
    if self.order_line_items
      total = 0
      self.order_line_items.each {|i| total += i.quantity_fulfilled }
      total
    end
  end
  
  def amount_fulfilled
    if self.order_line_items
      total = 0
      self.order_line_items.each {|i| total += (i.quantity_fulfilled.to_f * i.price.to_f) }
      total
    end
  end
  
end
