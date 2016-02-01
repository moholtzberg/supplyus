class CreateOrderLineItems < ActiveRecord::Migration
  def change
    create_table :order_line_items do |t|
      t.integer :order_id
      t.integer :order_line_number
      t.integer :item_id
      t.float :quantity
      t.float :price
      t.float :discount
      t.text :description
      t.timestamps null: false
    end
  end
end
