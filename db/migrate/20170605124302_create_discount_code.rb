class CreateDiscountCode < ActiveRecord::Migration
  def change
    create_table :discount_codes do |t|
      t.string :code
      t.integer :times_of_use
    end
  end
end
