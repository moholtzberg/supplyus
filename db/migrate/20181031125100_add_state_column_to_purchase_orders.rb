class AddStateColumnToPurchaseOrders < ActiveRecord::Migration
  
  def self.up
    add_column :purchase_orders, :state, :string
  end
  
  def self.down
    remove_column :purchase_orders, :state, :string
  end
  
end
