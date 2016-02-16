class AddQuantityCanceledOrderLineItems < ActiveRecord::Migration
  def change
    add_column :order_line_items, :quantity_canceled, :integer
  end
end
