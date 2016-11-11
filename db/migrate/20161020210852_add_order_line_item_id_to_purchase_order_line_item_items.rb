class AddOrderLineItemIdToPurchaseOrderLineItemItems < ActiveRecord::Migration
  def change
    add_column :purchase_order_line_items, :order_line_item_id, :integer
  end
end
