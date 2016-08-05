class CreateInventory < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.belongs_to :item, :null => false
      t.integer :qty_on_hand
      t.integer :qty_sold
      t.integer :qty_shipped
      t.integer :qty_ordered
      t.integer :qty_received
      t.integer :qty_backordered
      t.timestamps
    end
  end
end
