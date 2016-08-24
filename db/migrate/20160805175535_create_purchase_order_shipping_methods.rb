class CreatePurchaseOrderShippingMethods < ActiveRecord::Migration
  def change
    create_table :purchase_order_shipping_methods do |t|
      t.belongs_to :purchase_order
      t.belongs_to :shipping_method
      t.float :amount
      t.timestamps
    end
  end
end
