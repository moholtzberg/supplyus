class AddRefundedToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :refunded, :decimal, precision: 10, scale: 2
  end
end
