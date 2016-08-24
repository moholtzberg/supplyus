class AddBillToEmailToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :bill_to_email, :string
  end
end