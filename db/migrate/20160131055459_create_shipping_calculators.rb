class CreateShippingCalculators < ActiveRecord::Migration
  def change
    create_table :shipping_calculators do |t|
      t.string :name
      t.text :description
      t.string :calculation_method
      t.string :calculation_amount
    end
  end
end
