class CreateLineItemFulfillments < ActiveRecord::Migration
  def change
    create_table :line_item_fulfillments do |t|
      t.belongs_to :order_line_item
      t.belongs_to :invoice
      t.integer :quantity_fulfilled
      t.datetime :date
    end
  end
end