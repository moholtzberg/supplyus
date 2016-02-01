class CreateItemVendorPrices < ActiveRecord::Migration
  def change
    create_table :item_vendor_prices do |t|
      t.integer :item_id
      t.integer :vendor_id
      t.float :price
      t.timestamps null: false
    end
  end
end
