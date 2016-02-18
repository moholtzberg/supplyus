class OrderLineItem < ActiveRecord::Base
  
  default_scope { order(:order_line_number) }
  
  belongs_to :order
  belongs_to :item
  belongs_to :cart, :class_name => :order, :foreign_key => :order_id
  has_many :line_item_shipments
  has_many :line_item_fulfillments
  
  scope :by_item, -> (item) { where(:item_id => item) }
  scope :active,  -> () { where(:quantity => 1..Float::INFINITY) }
  
  
  before_create :make_line_number, :on => :create
  
  validates :order_line_number, :uniqueness => {
    :scope => :order_id
  }
  
  validates :item_id, :uniqueness => {
    :scope => :order_id
  }

  def make_line_number
    if self.order_id.blank?
      puts "NO ORDER YETTTTTTTTTTTTTTTTTTTTTTTTTTTTTT"
    else
      self.order_line_number = self.order.order_line_items.count + 1
    end
  end
  
  def actual_quantity
    quantity.to_f - quantity_canceled.to_f
  end
  
  def sub_total
    actual_quantity.to_f * price.to_f
  end
  
  def shipped
    # if self.line_item_shipments
    #   total = 0
    #   self.line_item_shipments.each {|i| total += i.quantity_shipped }
    #   total == quantity
    # else
    #   false
    # end
    LineItemShipment.where(:order_line_item_id => 4).group(:order_line_item_id).sum(:quantity_shipped).inject(0) {|k, v| (k + v[1]) != 0 ? true : false }
  end
  
  def quantity_shipped
    # if self.line_item_shipments
    #   total = 0
    #   self.line_item_shipments.each {|i| total += i.quantity_shipped }
    #   total
    # end
    LineItemShipment.where(:order_line_item_id => 1).group(:order_line_item_id).sum(:quantity_shipped).inject(0) {|sum, k| sum + k[1] }
  end
  
  def fulfilled
    # if self.line_item_fulfillments
    #   total = 0
    #   self.line_item_fulfillments.each {|i| total += i.quantity_fulfilled }
    #   total == quantity
    # else
    #   false
    # end
     LineItemFulfillment.where(:order_line_item_id => 4).group(:order_line_item_id).sum(:quantity_shipped).inject(0) {|k, v| (k + v[1]) != 0 ? true : false }
  end
  
  def quantity_fulfilled
    # if self.line_item_fulfillments
    #   total = 0
    #   self.line_item_fulfillments.each {|i| total += i.quantity_fulfilled }
    #   total
    # end
    LineItemFulfillment.where(:order_line_item_id => 1).group(:order_line_item_id).sum(:quantity_fulfilled).inject(0) {|sum, k| sum + k[1] }
  end
  
end