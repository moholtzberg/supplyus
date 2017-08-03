class RemoveCanceledFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :canceled
  end
end
