class InventoryTransaction < ActiveRecord::Base
  
  belongs_to :inv_transaction, :polymorphic => true
  belongs_to :item, -> { includes(:inventory) }, :touch => true
  
  after_commit :update_inventory
  
  def update_inventory
    puts "SOLD -> #{item.number} -> #{qty_sold_by_item}"
    puts "SHIPPED -> #{item.number} -> #{qty_shipped_by_item}"
    puts "ORDERED -> #{item.number} -> #{qty_ordered_by_item}"
    puts "RECEIVED -> #{item.number} -> #{qty_received_by_item}"
    i = Inventory.find_or_create_by(:item_id => item_id)
    i.update_attributes(:qty_sold => qty_sold_by_item, :qty_shipped => qty_shipped_by_item, :qty_ordered => qty_ordered_by_item, :qty_received => qty_received_by_item)
  end
  
  def qty_shipped_by_item
    InventoryTransaction.where(item_id: self.item_id, inv_transaction_type: "LineItemShipment").map(&:quantity).sum
  end
  
  def qty_received_by_item
    InventoryTransaction.where(item_id: self.item_id, inv_transaction_type: "PurchaseOrderLineItemReceipt").map(&:quantity).sum
  end
  
  def qty_sold_by_item
    InventoryTransaction.where(item_id: self.item_id, inv_transaction_type: "OrderLineItem").map(&:quantity).sum
  end
  
  def qty_ordered_by_item
    InventoryTransaction.where(item_id: self.item_id, inv_transaction_type: "PurchaseOrderLineItem").map(&:quantity).sum
  end
  
end