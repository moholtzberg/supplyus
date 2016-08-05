class Inventory < ActiveRecord::Base
  
  belongs_to :item, -> { includes(:inventory_transactions) }
  has_many :inventory_transactions, :through => :item
  
  validates_uniqueness_of :item_id
  
  before_save :set_quantities
  
  def set_quantities
    self.qty_on_hand = (qty_received.to_i - qty_shipped.to_i)
    puts "qty_on_hand ---> #{qty_on_hand}"
    self.qty_backordered = (qty_sold.to_i - (qty_on_hand.to_i + qty_shipped.to_i) )
  end
  
  def quantity_on_order
    qty_ordered - qty_received
  end
  
  def quantity_allocated
    qty_sold - qty_shipped
  end
  
  def quantity_available
    (quantity_on_hand + quantity_on_order) - (quantity_allocated + quantity_shipped)
  end
  
  def quantity_on_hand
    qty_on_hand
  end
  
  def quantity_shipped
    qty_shipped
  end
  
  def self.out_of_stock
    ids = Inventory.all.map {|a| if a.quantity_available.to_i < 0 then a.id end}
    Inventory.where(id: ids)
  end
  
end