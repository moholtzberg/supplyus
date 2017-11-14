class InventoryTransaction < ActiveRecord::Base
  belongs_to :inv_transaction, polymorphic: true
  belongs_to :inventory

  delegate :ancestor, :ancestor_title, to: :inv_transaction
  after_commit :update_inventory

  def update_inventory
    puts "SHIPPED -> #{inventory.item.number} -> #{qty_shipped_by_item}"
    puts "RECEIVED -> #{inventory.item.number} -> #{qty_received_by_item}"
    inventory.update_attributes(
      qty_shipped: qty_shipped_by_item,
      qty_received: qty_received_by_item
    )
  end

  def qty_shipped_by_item
    qty = InventoryTransaction.where(
      inventory_id: inventory_id,
      inv_transaction_type: 'LineItemShipment'
    ).sum('quantity')
    qty -= InventoryTransaction.where(
      inventory_id: inventory_id,
      inv_transaction_type: 'Transfer'
    ).where('quantity < 0').sum('quantity')
    qty
  end

  def qty_received_by_item
    qty = InventoryTransaction.where(
      inventory_id: inventory_id,
      inv_transaction_type: %w[PurchaseOrderLineItemReceipt LineItemReturn]
    ).sum('quantity')
    qty += InventoryTransaction.where(
      inventory_id: inventory_id,
      inv_transaction_type: 'Transfer'
    ).where('quantity > 0').sum('quantity')
    qty
  end
end
