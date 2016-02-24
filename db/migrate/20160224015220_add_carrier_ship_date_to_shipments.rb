class AddCarrierShipDateToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :carrier, :string
    add_column :shipments, :ship_date, :datetime
  end
end
