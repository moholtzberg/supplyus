class AddOrderToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :order_id, :integer
  end
end
