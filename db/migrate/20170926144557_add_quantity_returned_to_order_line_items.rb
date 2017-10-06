class AddQuantityReturnedToOrderLineItems < ActiveRecord::Migration
  def change
    add_column :order_line_items, :quantity_returned, :integer
  end
end
