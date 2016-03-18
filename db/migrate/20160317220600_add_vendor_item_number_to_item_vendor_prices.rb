class AddVendorItemNumberToItemVendorPrices < ActiveRecord::Migration
  def change
    add_column :item_vendor_prices, :vendor_item_number, :string
  end
end
