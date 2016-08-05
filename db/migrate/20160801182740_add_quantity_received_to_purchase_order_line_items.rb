class AddQuantityReceivedToPurchaseOrderLineItems < ActiveRecord::Migration
  def change
    add_column :purchase_order_line_items, :quantity_received, :integer, :default => 0
  end
end
