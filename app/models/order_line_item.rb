class OrderLineItem < ActiveRecord::Base

  belongs_to :order
  belongs_to :item
  belongs_to :cart, :class_name => :order, :foreign_key => :order_id
  # before_save :make_subtotal
  
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
  
  def sub_total
    quantity * price
  end

  # def make_subtotal
  #   self.sub_total = (self.price.to_f * self.quantity.to_f)
  # end
  
end