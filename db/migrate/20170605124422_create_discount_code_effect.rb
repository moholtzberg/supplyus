class CreateDiscountCodeEffect < ActiveRecord::Migration
  def change
    create_table :discount_code_effects do |t|
      t.float :amount
      t.float :percent
      t.boolean :shipping
      t.integer :quantity
      t.integer :item_id
      t.integer :appliable_id
      t.string :appliable_type
    end
  end
end
