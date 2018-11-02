class CreateAccountShippingMethod < ActiveRecord::Migration
  def change
    create_table :account_shipping_methods do |t|
      t.integer  :account_id
      t.integer :shipping_method_id
    end
  end
end
