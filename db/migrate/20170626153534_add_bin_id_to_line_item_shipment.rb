class AddBinIdToLineItemShipment < ActiveRecord::Migration
  def change
    add_column :line_item_shipments, :bin_id, :integer
  end
end
