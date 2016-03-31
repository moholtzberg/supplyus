class Order < ActiveRecord::Base
  
  include ApplicationHelper
  
  scope :is_locked, -> () { where(:locked => true) }
  scope :is_unlocked, -> () { where.not(:locked => true) }
  scope :is_complete, -> () { where.not(:completed_at => nil)}
  scope :is_incomplete, -> () { where(:completed_at => nil)}
  scope :has_account, -> () { where.not(:account_id => nil) }
  scope :no_account, -> () { where(:account_id => nil) }
 
  belongs_to :account
  has_one :order_shipping_method
  has_many :order_line_items, :dependent => :destroy, :inverse_of => :order
  has_many :items, :through => :order_line_items
  has_many :order_payment_applications
  has_many :payments, :through => :order_payment_applications
  
  accepts_nested_attributes_for :order_line_items, :allow_destroy => true
  
  before_save :make_record_number
  
  after_commit :flush_cache
  
  def flush_cache
    Rails.cache.delete([self.class.name,"open_orders"])
  end
  
  def self.shipped
    Rails.cache.fetch([name, "shipped_orders"]) {
      ids = Order.joins(:order_line_items).distinct(:order_id).map {|o| if o.shipped == true then o.id end }
      Order.where(id: ids)
    }
    # Order.joins(:order_line_items => :line_item_shipments).group(:order_id, :order_line_item_id).sum("line_item_shipments.quantity_shipped").sum("order_line_items.quantity").inject(0) {|k, v| (k + v[1]) != 0 ? true : false }
    # Order.joins(:order_line_items).joins(:line_item_shipments).group(:order_id, :order_line_item_id).sum("line_item_shipments.quantity_shipped").inject(0) {|k, v| (k + v[1]) != 0 ? true : false }
    # Order.joins(:order_line_items => :line_item_shipments).group(:order_id, :order_line_item_id, :quantity, :quantity_canceled, :quantity_shipped).sum(:quantity).inject(0) {|sum, k| sum + (k[0][1].to_f - k[0][2].to_f)}
    # sql = "SELECT o.id, o.number, oli.order_line_number, 
    # SUM(IFNULL(oli.quantity,0)) - SUM(IFNULL(oli.quantity_canceled,0)) AS qty,
    # ls.order_line_item_id, ls.quantity_shipped
    # FROM orders o
    # LEFT JOIN order_line_items  oli ON o.id = oli.order_id
    # LEFT JOIN line_item_shipments ls ON oli.id = ls.order_line_item_id
    # GROUP BY o.id, o.number, oli.order_line_number, ls.order_line_item_id, ls.quantity_shipped
    # HAVING  SUM(IFNULL(oli.quantity,0)) - SUM(IFNULL(oli.quantity_canceled,0)) = ls.quantity_shipped AND ls.quantity_shipped >= 1"
    # # Order.connection.execute(sql)
    # # Arel::Nodes::SqlLiteral.new(sql)
    # orders = Arel::Table.new(:orders)
    # order_line_items = Arel::Table.new(:order_line_items)
    # line_item_shipments = Arel::Table.new(:line_item_shipments)
    # orders.join(:order_line_items).on(orders[:id].eq(order_line_items[:order_id]))
    # .join(:line_item_shipments).on(order_line_items[:id].eq(line_item_shipments[:order_line_item_id]))
    # # .group_by
    # .having(order_line_items[:quantity].eq(line_item_shipments[:quantity_shipped]))
  end
  
  def self.fulfilled
    Rails.cache.fetch([name, "fulfilled_orders"]) {
      ids = Order.joins(:order_line_items).distinct(:order_id).map {|o| if o.fulfilled == true then o.id end }
      Order.where(id: ids)
    }
  end
  
  def self.open
    Rails.cache.fetch([name, "open_orders"]) {
      ids = Order.joins(:order_line_items).distinct(:order_id).map {|o| if o.shipped == false then o.id end }
      Order.where(id: ids)
    }
  end
  
  def self.empty
    Order.includes(:order_line_items).where(:order_line_items => {:order_id => nil})
    # Order.all.select { |o| o.has_no_line_items }
  end
    
  def sub_total
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_sub_total"]) {
      OrderLineItem.where(order_id: id).group(:order_line_number, :price, :quantity, :quantity_canceled).sum(:price, :quantity).inject(0) {|sum, k| sum + (k[0][1].to_f * (k[0][2].to_f - k[0][3].to_f))}
    }
  end
  
  def shipping_total
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipping_total"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_open")
      order_shipping_method.amount unless order_shipping_method.nil?
    }
  end
  
  def total
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_total"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_open")
      sub_total.to_f + shipping_total.to_f
    }
  end
  
  def quantity
    # if self.order_line_items
    #   total = 0
    #   self.order_line_items.each {|i| total += i.actual_quantity }
    #   total
    # end
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity"]) {
      OrderLineItem.where(order_id: id).group(:order_line_number, :quantity, :quantity_canceled).sum(:quantity).inject(0) {|sum, k| sum + (k[0][1].to_f - k[0][2].to_f)}
    }
  end
  
  def shipped
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipped"]) {
      if self.order_line_items
        total = 0
        self.order_line_items.each {|i| total += i.quantity_shipped }
        total == quantity
      else
        false
      end
    }
  end
  
  def quantity_shipped
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity_shipped"]) {
      if self.order_line_items
        total = 0
        self.order_line_items.each {|i| total += i.quantity_shipped }
        total
      end
    }
  end
  
  def amount_shipped
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_amount_shipped"]) {
      if self.order_line_items
        total = 0
        self.order_line_items.each {|i| total += (i.quantity_shipped.to_f * i.price.to_f) }
        total
      end
    }
  end
  
  def fulfilled
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_fulfilled"]) {
      if self.order_line_items
        total = 0
        self.order_line_items.each {|i| total += i.quantity_fulfilled }
        total == quantity
      else
        false
      end
    }
  end
  
  def quantity_fulfilled
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity_fulfilled"]) {
      if self.order_line_items
        total = 0
        self.order_line_items.each {|i| total += i.quantity_fulfilled }
        total
      end
    }
  end
  
  def amount_fulfilled
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_amount_fulfilled"]) {
      if self.order_line_items
        total = 0
        self.order_line_items.each {|i| total += (i.quantity_fulfilled.to_f * i.price.to_f) }
        total
      end
    }
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
        self.completed_at + account.payment_terms
      else
        self.completed_at + 30.days
      end
    end
  end
  
  
end
