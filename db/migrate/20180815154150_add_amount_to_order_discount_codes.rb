class AddAmountToOrderDiscountCodes < ActiveRecord::Migration
  def self.up
    add_column :order_discount_codes, :amount, :decimal, :precision => 10, :scale => 2
  end

  def self.down
    remove_column :order_discount_codes, :amount
  end
end
