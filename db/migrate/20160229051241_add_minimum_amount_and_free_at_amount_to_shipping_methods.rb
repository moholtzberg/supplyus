class AddMinimumAmountAndFreeAtAmountToShippingMethods < ActiveRecord::Migration
  def change
    add_column :shipping_methods, :minimum_amount, :float
    add_column :shipping_methods, :free_at_amount, :float
  end
end
