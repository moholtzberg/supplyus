class AddIndexToOrderLineItems < ActiveRecord::Migration
  def change
    add_index :order_line_items, :id, :name => 'order_line_item_id_ix'
    add_index :order_line_items, :order_id, :name => 'order_line_item_order_id_ix'
    add_index :order_line_items, :item_id, :name => 'order_line_item_item_id_ix'
  end
end
