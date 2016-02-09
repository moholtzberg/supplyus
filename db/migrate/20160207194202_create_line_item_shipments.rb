class CreateLineItemShipments < ActiveRecord::Migration
  def change
    create_table :line_item_shipments do |t|
      t.belongs_to :order_line_item
      t.belongs_to :shipment
      t.integer :quantity_shipped
      t.datetime :date
    end
  end
end
