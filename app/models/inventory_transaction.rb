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
    qty = InventoryTransaction.where(inventory_id: self.inventory_id, inv_transaction_type: "LineItemShipment").sum("quantity")
    qty -= InventoryTransaction.where(inventory_id: self.inventory_id, inv_transaction_type: "Transfer").where('quantity < 0').sum("quantity")
    qty
  end
  
  def qty_received_by_item
    qty = InventoryTransaction.where(inventory_id: self.inventory_id, inv_transaction_type: "PurchaseOrderLineItemReceipt").sum("quantity")
    qty += InventoryTransaction.where(inventory_id: self.inventory_id, inv_transaction_type: "Transfer").where('quantity > 0').sum("quantity")
    qty
  end

  def ancestor
    case inv_transaction_type
    when "LineItemShipment"
      self.inv_transaction.order_line_item.order
    when "PurchaseOrderLineItemReceipt"
      self.inv_transaction.purchase_order_receipt.purchase_order
    when "Transfer"
      self.inv_transaction
    end
  end

  def ancestor_title
    case inv_transaction_type
    when "LineItemShipment"
      self.ancestor.number
    when "PurchaseOrderLineItemReceipt"
      self.ancestor.number
    when "Transfer"
       "#{self.ancestor.from.bin.name} - #{self.ancestor.to.name} Transfer" 
    end
  end
end