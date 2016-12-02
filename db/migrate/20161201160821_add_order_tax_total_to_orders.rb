class AddOrderTaxTotalToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :tax_total, :decimal, :precision => 10, :scale => 2, :default => 0.00
  end
end
