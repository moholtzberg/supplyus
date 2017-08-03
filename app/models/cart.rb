class Cart < Order
  
  default_scope { where(submitted_at: nil) }
  
  has_many :contents, :class_name => "OrderLineItem", :foreign_key => :order_id
  
  accepts_nested_attributes_for :contents
  
  def item_count
    stuff = 0
    contents.each {|li| stuff = stuff + li.quantity.to_i}
    stuff
  end
  
  def cart_total
    total = 0
    contents.each {|li| total = total + li.sub_total}
    total
  end
  
  def empty?
    item_count == 0 ? true : false
  end
  
end