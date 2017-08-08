class PurchaseOrderLineItem < ActiveRecord::Base
  
  default_scope { order(:purchase_order_line_number) }
  
  belongs_to :purchase_order, :touch => true
  belongs_to :item
  belongs_to :order_line_item
  has_many :purchase_order_line_item_receipts
  
  scope :by_item, -> (item) { where(:item_id => item) }
  scope :active,  -> () { where(:quantity => 1..Float::INFINITY) }
  
  before_create :make_line_number, :on => :create
  
  validates :purchase_order_line_number, :uniqueness => {
    :scope => :purchase_order_id
  }
  
  validates :item_id, :uniqueness => {
    :scope => :purchase_order_id
  }
  
  validate :linked_order_line_item_is_correct
  
  def linked_order_line_item_is_correct
    puts "trying to validate"
    if order_line_item_id.present?
      if order_line_item.item_id != item_id
        errors.add(:order_line_item_id, "Item's do not match")
      end
      # if order_line_item.actual_quantity < (PurchaseOrderLineItem.where(:order_line_item_id => order_line_item_id).map(&:quantity).sum + quantity)
#         puts order_line_item.actual_quantity
#         puts (PurchaseOrderLineItem.where(:order_line_item_id => order_line_item_id).map(&:quantity).sum + quantity)
#         errors.add(:order_line_item_id, "quantity + quantity already purchased is greater than the Order quantity needed")
#       end
    end
  end
  
  validates :item_id, :presence => true
  
  after_commit :update_received, :if => :persisted?
  
  def update_received
    qr = calculate_quantity_received
    self.update_columns(:quantity_received => qr)
  end
  
  def calculate_quantity_received
    if self.purchase_order_line_item_receipts
      total = 0
      self.purchase_order_line_item_receipts.each {|i| total += i.quantity_received.to_f }
      total
    end
  end
  
  def make_line_number
    if self.purchase_order_id.blank?
    else
      max = [self.purchase_order.purchase_order_line_items.count, (self.purchase_order.purchase_order_line_items.last.nil? ? 0 : self.purchase_order.purchase_order_line_items.last.purchase_order_line_number)].max
      self.purchase_order_line_number = max + 1
    end
  end
  
  def item_number
    item.try(:number)
  end
  
  def item_number=(name)
    puts name
    self.item = Item.find_by(:number => name) if name.present?
    puts self.item.number
  end
  
  def sub_total
    quantity.to_i * price.to_s.to_d
  end
  
  def amount_received
    quantity_received.to_i * price.to_f.to_d
  end
  
end