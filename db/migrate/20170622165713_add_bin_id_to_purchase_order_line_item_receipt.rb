class AddBinIdToPurchaseOrderLineItemReceipt < ActiveRecord::Migration
  def change
    add_column :purchase_order_line_item_receipts, :bin_id, :integer
  end
end
