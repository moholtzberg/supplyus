class CreatePurchaseOrderLineItemReceipts < ActiveRecord::Migration
  def change
    create_table :purchase_order_line_item_receipts do |t|
      t.belongs_to :purchase_order_line_item
      t.belongs_to :purchase_order_receipt
      t.integer :quantity_received
      t.datetime :date
    end
  end
end
