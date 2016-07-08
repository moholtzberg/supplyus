class AddAppliedAmountToOrderPaymentApplications < ActiveRecord::Migration
  def change
    add_column :order_payment_applications, :applied_amount, :float
  end
end
