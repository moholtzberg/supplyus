class OrderLineItem < ActiveRecord::Base
  
  default_scope { order(:order_line_number) }
  
  belongs_to :order, :touch => true
  belongs_to :item
  belongs_to :cart, :class_name => :order, :foreign_key => :order_id
  has_many :line_item_shipments
  has_many :shipments, :through => :line_item_shipments
  has_many :line_item_fulfillments
  has_many :purchase_order_line_items
  has_many :purchase_orders, :through => :purchase_order_line_items
  
  scope :by_item, -> (item) { where(:item_id => item) }
  scope :by_category, -> (category) { joins(item: :item_categories).where('items.category_id = ? or item_categories.category_id = ?', category, category).distinct }
  scope :active,  -> () { where("order_line_items.quantity <> 0") }
  
  before_create :make_line_number, :on => :create  
  
  validates_uniqueness_of :order_line_number, :scope => :order_id
  validates_uniqueness_of :item_id, :scope => :order_id, unless: Proc.new {|line| line.item.item_type_id == 99 || (line.description.match(/ID# Q[0-9]{5}.+/) != nil if line.description.present?)}
  
  validates :item_id, :presence => true
  
  after_commit :update_shipped_fulfilled, :if => :persisted?
  after_commit :flush_cache
  
  def line_description_not_same_as_other
    approve = true
    other_lines = OrderLineItem.where(order_id: self.order_id).where.not(id: self.id)
    puts other_lines
    other_lines.map {|a| approve = (a.description.match(/self.description/) != nil) ? true : false }
    puts approve
    approve
  end
  
  def update_shipped_fulfilled
    qs = calculate_quantity_shipped
    qf = calculate_quantity_fulfilled
    self.update_columns(:quantity_shipped => qs, :quantity_fulfilled => qf)
  end
  
  def item_number
    item.try(:number)
  end
  
  def item_number=(name)
    puts name
    self.item = Item.find_by(:number => name) if name.present?
    puts self.item.number
  end
  
  def quantities_not_linked_to_po
    actual_quantity.to_i - purchase_order_line_items.map(&:quantity).sum.to_i
  end
  
  def flush_cache
    Rails.cache.delete("open_orders")
  end
  
  def make_line_number
    if self.order_id.blank?
    else
      max = [self.order.order_line_items.count, (self.order.order_line_items.last.nil? ? 0 : self.order.order_line_items.last.order_line_number.to_i)].max
      self.order_line_number = max + 1
    end
  end
  
  def actual_quantity
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_actual_quantity"]) {
      quantity.to_f - quantity_canceled.to_f
    }
  end
  
  def sub_total
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_sub_total"]) {
      actual_quantity * price
    }
  end
  
  def profit
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_profit"]) {
      if !item.nil? and !item.cost_price.nil?
        tc = actual_quantity.to_i * item.cost_price
        sub_total - tc
      else
        0.00
      end
    }
  end
  
  def shipped
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipped"]) {
      quantity_shipped == actual_quantity
    }
  end
  
  def unshipped
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_unshipped"]) {
      quantity_shipped != actual_quantity
    }
  end
  
  def shipped_id
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipped_id"]) {
      id if shipped
    }
  end
  
  def amount_shipped
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_amount_shipped"]) {
      quantity_shipped.to_i * price.to_f.to_d
    }
  end
  
  def calculate_quantity_shipped
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_calculate_quantity_shipped"]) {
      if self.line_item_shipments
        total = 0
        self.line_item_shipments.each {|i| total += i.quantity_shipped.to_f }
        total
      end
    }
  end
  
  def fulfilled
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_fulfilled"]) {
      quantity_fulfilled == actual_quantity
    }
  end
  
  def unfulfilled
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_unfulfilled"]) {
      quantity_fulfilled != actual_quantity
    }
  end
  
  def fulfilled_id
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_fulfilled_id"]) {
      id if fulfilled
    }
  end
  
  def amount_fulfilled
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_amount_fulfilled"]) {
      quantity_fulfilled.to_d * price.to_d
    }
  end
  
  def calculate_quantity_fulfilled
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_calculate_quantity_fulfilled"]) {
      if self.line_item_fulfillments
        total = 0
        self.line_item_fulfillments.each {|i| total += i.quantity_fulfilled.to_i }
        total
      end
    }
  end
  
end