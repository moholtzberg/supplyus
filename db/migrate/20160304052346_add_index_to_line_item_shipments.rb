class AddIndexToLineItemShipments < ActiveRecord::Migration
  def change
    add_index :line_item_shipments, :id, :name => 'line_item_shipment_id_ix'
    add_index :line_item_shipments, :order_line_item_id, :name => 'line_item_shipment_order_line_item_id_ix'
    add_index :line_item_shipments, :shipment_id, :name => 'line_item_shipment_shipment_id_ix'
  end
end
