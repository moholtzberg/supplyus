class LineItemShipment < ActiveRecord::Base
  
  belongs_to :order_line_item, :touch => true
  belongs_to :shipment, :touch => true
  has_many :inventory_transactions, :as => :inv_transaction
  
  after_commit :flush_cache
  after_commit :create_inventory_transactions
  
  def create_inventory_transactions
    i = InventoryTransaction.find_or_create_by(:inv_transaction_id => id, :inv_transaction_type => "LineItemShipment", :item_id => order_line_item.item_id, :quantity => quantity_shipped)
    i.update_attributes(:item_id => order_line_item.item_id, :quantity => quantity_shipped)
  end
  
  
  def flush_cache
    Rails.cache.delete("open_orders")
  end
  
end