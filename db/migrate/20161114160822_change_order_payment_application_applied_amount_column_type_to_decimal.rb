class ChangeOrderPaymentApplicationAppliedAmountColumnTypeToDecimal < ActiveRecord::Migration
  
  def self.up
    change_column :order_payment_applications, :applied_amount, :decimal, :precision => 10, :scale => 2
  end
  
  def self.down
    change_column :order_payment_applications, :applied_amount, :float
  end
  
end
