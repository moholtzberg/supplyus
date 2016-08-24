class CreatePurchaseOrderLineItems < ActiveRecord::Migration
  def change
    create_table :purchase_order_line_items do |t|
      t.integer :purchase_order_id
      t.integer :purchase_order_line_number
      t.integer :item_id
      t.float :quantity
      t.float :price
      t.float :discount
      t.text :description
    end
  end
end
