class CreateShippingMethods < ActiveRecord::Migration
  def change
    create_table :shipping_methods do |t|
      t.integer :shipping_calculator_id
      t.string :name
      t.float :rate
      t.text :description
      t.boolean :active
    end
  end
end
