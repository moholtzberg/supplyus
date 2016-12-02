class ChangeColumnDefaultOnOrderPaymentApplicationsAppliedAmount < ActiveRecord::Migration
  def self.up
    change_column_default(:order_payment_applications, :applied_amount, 0.0)
  end
  
  def self.down
    change_column_default(:order_payment_applications, :applied_amount, nil)
  end
end
