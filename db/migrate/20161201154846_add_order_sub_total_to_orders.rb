class AddOrderSubTotalToOrders < ActiveRecord::Migration
  def change
     add_column :orders, :sub_total, :decimal, :precision => 10, :scale => 2, :default => 0.00
  end
end