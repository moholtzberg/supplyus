class PurchaseOrderLineItemReceipt < ActiveRecord::Base
  
  belongs_to :purchase_order_line_item
  belongs_to :purchase_order_receipt
  belongs_to :bin
  has_many :inventory_transactions, as: :inv_transaction, dependent: :destroy
  
  after_commit :create_inventory_transactions, on: :create
  after_commit :recalculate_line_item
  
  def create_inventory_transactions
    if InventoryTransaction.find_by(:inv_transaction_id => id, :inv_transaction_type => "PurchaseOrderLineItemReceipt")
      i = InventoryTransaction.find_by(:inv_transaction_id => id, :inv_transaction_type => "PurchaseOrderLineItemReceipt")
    else
      i = InventoryTransaction.new
    end
    i.update_attributes(:inv_transaction_id => id, :inv_transaction_type => "PurchaseOrderLineItemReceipt", :inventory_id => bin.inventories.find_or_create_by(item_id: purchase_order_line_item.item_id).id, :quantity => quantity_received)
  end

  def recalculate_line_item
    self.purchase_order_line_item.update_received
  end
  
end