class LineItemShipment < ActiveRecord::Base
  
  belongs_to :order_line_item, :touch => true
  belongs_to :shipment, :touch => true
  belongs_to :bin
  has_many :inventory_transactions, :as => :inv_transaction, dependent: :destroy
  
  after_commit :flush_cache
  after_commit :create_inventory_transactions, on: :create
  after_commit :recalculate_line_item
  
  def create_inventory_transactions
    if InventoryTransaction.find_by(:inv_transaction_id => id, :inv_transaction_type => "LineItemShipment")
      i = InventoryTransaction.find_by(:inv_transaction_id => id, :inv_transaction_type => "LineItemShipment")
    else
      i = InventoryTransaction.new
    end
    i.update_attributes(:inv_transaction_id => id, :inv_transaction_type => "LineItemShipment", :inventory_id => bin.inventories.find_by(item_id: order_line_item.item_id).id, :quantity => quantity_shipped)
  end
  
  
  def flush_cache
    Rails.cache.delete("open_orders")
  end

  def recalculate_line_item
    self.order_line_item.update_shipped_fulfilled
  end
  
end