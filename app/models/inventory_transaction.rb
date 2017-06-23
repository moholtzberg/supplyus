class InventoryTransaction < ActiveRecord::Base
  
  belongs_to :inv_transaction, :polymorphic => true
  belongs_to :inventory
  
  after_commit :update_inventory
  
  def update_inventory
    puts "SHIPPED -> #{inventory.item.number} -> #{qty_shipped_by_item}"
    puts "RECEIVED -> #{inventory.item.number} -> #{qty_received_by_item}"
    inventory.update_attributes(:qty_shipped => qty_shipped_by_item, :qty_received => qty_received_by_item)
  end
  
  def qty_shipped_by_item
    InventoryTransaction.where(inventory_id: self.inventory_id, inv_transaction_type: "LineItemShipment").sum("quantity")
  end
  
  def qty_received_by_item
    InventoryTransaction.where(inventory_id: self.inventory_id, inv_transaction_type: "PurchaseOrderLineItemReceipt").sum("quantity")
  end
    
end