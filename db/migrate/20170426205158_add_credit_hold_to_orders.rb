class AddCreditHoldToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :credit_hold, :boolean, :default => false
  end
end
