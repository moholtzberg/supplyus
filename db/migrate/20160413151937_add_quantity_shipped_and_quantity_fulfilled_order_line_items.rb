class AddQuantityShippedAndQuantityFulfilledOrderLineItems < ActiveRecord::Migration
  def change
    add_column :order_line_items, :quantity_shipped, :integer, :default => 0
    add_column :order_line_items, :quantity_fulfilled, :integer, :default => 0
  end
end