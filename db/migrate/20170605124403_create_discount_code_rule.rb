class CreateDiscountCodeRule < ActiveRecord::Migration
  def change
    create_table :discount_code_rules do |t|
      t.integer :quantity
      t.float :amount
      t.integer :requirable_id
      t.string :requirable_type
    end
  end
end
