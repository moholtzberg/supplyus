class Inventory < ActiveRecord::Base
  
  scope :with_items, -> () { where.not(:qty_on_hand => 0) }
  belongs_to :item
  belongs_to :bin
  has_many :inventory_transactions
  
  validates_uniqueness_of :item_id, scope: :bin_id
  
  before_save :set_quantities

  def self.lookup(word)
    includes(:item).includes(:bin).where("lower(items.number) like ? or lower(items.name) like ? or lower(bins.name) like ?", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%").references(:item, :bin)
  end
  
  def set_quantities
    self.qty_on_hand = (qty_received.to_i - qty_shipped.to_i)
    puts "qty_on_hand ---> #{qty_on_hand}"
    # self.qty_backordered = (qty_sold.to_i - (qty_on_hand.to_i + qty_shipped.to_i) )
  end
  
  # def quantity_on_order
  #   qty_ordered.to_i - qty_received.to_i
  # end
  
  # def quantity_allocated
  #   qty_sold.to_i - qty_shipped.to_i
  # end
  
  # def quantity_available
  #   (quantity_on_hand.to_i + quantity_on_order.to_i) - (quantity_allocated.to_i + quantity_shipped.to_i)
  #   # sum("SUM(COALESCE(qty_on_hand,0) + SUM(COALESCE(qty_ordered,0) - COALESCE(qty_received,0))) - SUM(COALESCE(qty_sold,0) - SUM(COALESCE(qty_shipped,0) + COALESCE(qty_shipped,0)))")
  # end
  
  def quantity_on_hand
    qty_on_hand.to_i
  end
  
  def quantity_shipped
    qty_shipped.to_i
  end
  
end