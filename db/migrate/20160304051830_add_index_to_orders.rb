class AddIndexToOrders < ActiveRecord::Migration
  def change
    add_index :orders, :id, :name => 'order_id_ix'
    add_index :orders, :account_id, :name => 'order_customer_id_ix'
  end
end
