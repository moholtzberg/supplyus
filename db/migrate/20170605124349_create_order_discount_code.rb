class CreateOrderDiscountCode < ActiveRecord::Migration
  def change
    create_table :order_discount_codes do |t|
      t.integer :discount_code_id
      t.integer :order_id
    end
  end
end
