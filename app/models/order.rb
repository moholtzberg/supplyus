class Order < ActiveRecord::Base
  
  include ApplicationHelper
  
  scope :is_locked, -> () { where(:locked => true) }
  scope :is_unlocked, -> () { where.not(:locked => true) }
  scope :is_complete, -> () { where.not(:completed_at => nil)}
  scope :is_incomplete, -> () { where(:completed_at => nil)}
  scope :has_account, -> () { where.not(:account_id => nil) }
  scope :no_account, -> () { where(:account_id => nil) }
  scope :by_date_range, -> (from, to) { where("due_date >= ? AND due_date <= ?", from, to) }
  # scope :shipped, -> () { where(:id => OrderLineItem.shipped.pluck(:order_id).uniq) }
  # scope :fulfilled, -> () { where(:id => LineItemFulfillment.pluck(:invoice_id).unpaid.uniq) }
  # scope :fulfilled, -> () { where(:id => OrderLineItem.fulfilled.pluck(:order_id).uniq) }
  scope :past_due_90, -> {fulfilled.unpaid.where(due_date: 61.days.ago..90.days.ago) }
  
  belongs_to :account
  belongs_to :user
  has_one :order_shipping_method
  has_many :order_line_items, :dependent => :destroy, :inverse_of => :order
  has_many :items, :through => :order_line_items
  has_many :order_payment_applications
  has_many :payments, :through => :order_payment_applications
  has_many :credit_card_payments, :through => :order_payment_applications
  
  accepts_nested_attributes_for :order_line_items, :allow_destroy => true
  
  before_save :make_record_number
  
  after_commit :flush_cache
  
  def self.lookup(term)
    includes({:account => [:group]}, {:order_line_items => [:item]}).where("lower(orders.number) like (?) or lower(orders.po_number) like (?) or lower(items.number) like (?) or lower(items.name) like (?) or lower(items.description) like (?) or lower(groups.name) like (?)", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%").references({:account => [:group]}, {:order_line_items => [:item]})
  end
  
  def flush_cache
    Rails.cache.delete([self.class.name,"open_orders"])
  end
  
  def self.fulfilled
    # Rails.cache.fetch([name, "fulfilled_orders"]) {
    #   ids = Order.joins(:order_line_items).distinct(:order_id).map {|o| if o.fulfilled == true then o.id end }
    #   Order.where(id: ids)
    # }
    ids = Order.is_complete.where(:id => OrderLineItem.all.map {|a| if a.fulfilled then a.order_id end}).map(&:fulfilled_id)
    Order.where(id: ids)
  end
  
  def self.unshipped
    # Rails.cache.fetch([name, "open_orders"]) {
    #   ids = Order.joins(:order_line_items).distinct(:order_id).map {|o| if o.shipped == false then o.id end }
    #   Order.where(id: ids)
    # }
    ids = Order.is_complete.where(:id => OrderLineItem.all.map {|a| if a.unshipped then a.order_id end}).map(&:unshipped_id)
    Order.where(id: ids)
  end
  
  def self.unfulfilled
    # Rails.cache.fetch([name, "fulfilled_orders"]) {
    #   ids = Order.joins(:order_line_items).distinct(:order_id).map {|o| if o.fulfilled == true then o.id end }
    #   Order.where(id: ids)
    # }
    ids = Order.is_complete.where(:id => OrderLineItem.all.map {|a| if a.unfulfilled then a.order_id end}).map(&:unfulfilled_id)
    Order.where(id: ids)
  end
  
  def self.shipped
    ids = Order.is_complete.where(:id => OrderLineItem.all.map {|a| if a.shipped then a.order_id end}).map(&:shipped_id)
    Order.where(id: ids)
  end
  
  def self.unpaid
    # Order.includes(:payments).where(:payments)
    Order.is_complete.where.not(:id => OrderPaymentApplication.select(:order_id).uniq).order(:due_date)
  end
  
  def self.empty
    Order.includes(:order_line_items).where(:order_line_items => {:order_id => nil})
  end
  
  def sub_total
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_sub_total"]) {
    #   OrderLineItem.where(order_id: id).group(:order_line_number, :price, :quantity, :quantity_canceled).sum(:price, :quantity).inject(0) {|sum, k| sum + (k[0][1].to_f * (k[0][2].to_f - k[0][3].to_f))}
    # }
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_sub_total"]) {
      order_line_items.map(&:sub_total).sum
    }
  end
  
  def shipping_total
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipping_total"]) {
    # Rails.cache.delete("#{self.class.to_s.downcase}_open")
    order_shipping_method.amount unless order_shipping_method.nil?
    # }
  end
  
  def total
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_total"]) {
    #   Rails.cache.delete("#{self.class.to_s.downcase}_open")
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_total"]) {
      sub_total.to_f + shipping_total.to_f
    }
    # }
  end
  
  def profit
    order_line_items.map(&:profit).sum
  end
  
  def quantity
    # if self.order_line_items
    #   total = 0
    #   self.order_line_items.each {|i| total += i.actual_quantity }
    #   total
    # end
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity"]) {
    # OrderLineItem.where(order_id: id).group(:order_line_number, :quantity, :quantity_canceled).sum(:quantity).inject(0) {|sum, k| sum + (k[0][1].to_f - k[0][2].to_f)}
    # }
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity"]) {
      order_line_items.map(&:actual_quantity).sum
    }
  end
  
  def shipped
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipped"]) {
    #   if self.order_line_items
    #     total = 0
    #     self.order_line_items.each {|i| total += i.quantity_shipped.to_i }
    #     total == quantity
    #   else
    #     false
    #   end
    # }
    quantity_shipped == quantity
  end
  
  def shipped_id
    id if shipped
  end
  
  def unshipped
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipped"]) {
    #   if self.order_line_items
    #     total = 0
    #     self.order_line_items.each {|i| total += i.quantity_shipped.to_i }
    #     total == quantity
    #   else
    #     false
    #   end
    # }
    quantity_shipped != quantity
  end
  
  def unfulfilled
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipped"]) {
    #   if self.order_line_items
    #     total = 0
    #     self.order_line_items.each {|i| total += i.quantity_shipped.to_i }
    #     total == quantity
    #   else
    #     false
    #   end
    # }
    quantity_fulfilled != quantity
  end
  
  def unshipped_id
    id if unshipped
  end
  
  def quantity_shipped
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity_shipped"]) {
    #   if self.order_line_items
    #     total = 0
    #     self.order_line_items.each {|i| total += i.quantity_shipped }
    #     total
    #   end
    # }
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity_shipped"]) {
      order_line_items.map(&:quantity_shipped).sum
    }
  end
  
  def amount_shipped
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_amount_shipped"]) {
    #   if self.order_line_items
    #     total = 0
    #     self.order_line_items.each {|i| total += (i.quantity_shipped.to_f * i.price.to_f) }
    #     total
    #   end
    # }
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_amount_shipped"]) {
      order_line_items.map(&:amount_shipped).sum
    }
  end
  
  def fulfilled
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_fulfilled"]) {
    #   if self.order_line_items
    #     total = 0
    #     self.order_line_items.each {|i| total += i.quantity_fulfilled.to_i }
    #     total == quantity
    #   else
    #     false
    #   end
    # }
    # order_line_items.each {|l| l.fulfilled(l.actual_qunatity)}
    quantity_fulfilled == quantity
  end
  
  def fulfilled_id
    id if fulfilled
  end
  
  def unfulfilled_id
    id if unfulfilled
  end
  
  def quantity_fulfilled
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity_fulfilled"]) {
    #   if self.order_line_items
    #     total = 0
    #     self.order_line_items.each {|i| total += i.quantity_fulfilled }
    #     total
    #   end
    # }
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity_fulfilled"]) {
      order_line_items.map(&:quantity_fulfilled).sum
    }
  end
  
  def amount_fulfilled
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_amount_fulfilled"]) {
    #   if self.order_line_items
    #     total = 0
    #     self.order_line_items.each {|i| total += (i.quantity_fulfilled.to_f * i.price.to_f) }
    #     total
    #   end
    # }
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_amount_fulfilled"]) {
      order_line_items.map(&:amount_fulfilled).sum
    }
  end
  
  def payments_total
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_payments_total"]) {
      total_paid = 0.0
      self.payments.each {|a| total_paid = total_paid + a.amount}
      total_paid
    }
  end
  
  def paid
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_paid"]) {
      total_paid = 0.0
      self.payments.each {|a| total_paid = total_paid + a.amount}
      total_paid == self.total ? true : false
    }
  end
  
  def balance_due
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_balance_due"]) {
      total_paid = 0.0
      puts self.payments.count
      self.payments.each {|a| total_paid = total_paid + a.amount}
      return (self.total.to_f - total_paid.to_f)
    }
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
  
  def past_due_days
    if self.due_date
      (Date.today.to_date - self.due_date.to_date).to_i
    else
      if account.payment_terms
        (Date.today.to_date - (self.completed_at + account.payment_terms).to_date).to_i
      else
        (Date.today.to_date - (self.completed_at + 30.days).to_date).to_i
      end
    end
  end
  
  def self.past_due_up_to_30
    # fulfilled.unpaid.map {|o| if (o.past_due_days <= 30) then o end }
    fulfilled.unpaid.where("due_date > ?", 30.days.ago)
  end
  
  def self.past_due_up_to_60
    # fulfilled.unpaid.map {|o| if (o.past_due_days >= 31 and o.past_due_days <= 60) then o end }
    fulfilled.unpaid.where("due_date <= ? AND due_date > ?", 30.days.ago, 60.days.ago)
  end
  
  def self.past_due_up_to_90
    # fulfilled.unpaid.map {|o| if (o.past_due_days >= 61 and o.past_due_days <= 90) then o end }
    fulfilled.unpaid.where("due_date <= ? AND due_date > ?", 60.days.ago, 90.days.ago)
  end
  
  def self.past_due_over_90
    # fulfilled.unpaid.map {|o| if (o.past_due_days >= 90) then o end }
    fulfilled.unpaid.where("due_date <= ?", 90.days.ago)
  end
  
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
