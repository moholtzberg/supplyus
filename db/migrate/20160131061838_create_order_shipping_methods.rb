class CreateOrderShippingMethods < ActiveRecord::Migration
  def change
    create_table :order_shipping_methods do |t|
      t.belongs_to :order
      t.belongs_to :shipping_method
      t.float :amount
      t.timestamps
    end
  end
end
