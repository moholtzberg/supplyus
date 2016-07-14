class ChangeColumnTypePriceToDecimal < ActiveRecord::Migration
  
  def self.up
    change_column :order_line_items, :price, :decimal, :precision => 10, :scale => 2, :null => false
    change_column :account_item_prices, :price, :decimal, :precision => 10, :scale => 2, :null => false
    change_column :group_item_prices, :price, :decimal, :precision => 10, :scale => 2, :null => false
    change_column :item_vendor_prices, :price, :decimal, :precision => 10, :scale => 2, :null => false
    change_column :items, :price, :decimal, :precision => 10, :scale => 2
    change_column :items, :sale_price, :decimal, :precision => 10, :scale => 2
    change_column :items, :cost_price, :decimal, :precision => 10, :scale => 2
    change_column :order_shipping_methods, :amount, :decimal, :precision => 10, :scale => 2
    change_column :payments, :amount, :decimal, :precision => 10, :scale => 2, :null => false
    change_column :shipping_methods, :rate, :decimal, :precision => 10, :scale => 2
    change_column :transactions, :amount, :decimal, :precision => 10, :scale => 2, :null => false
  end
  
  def self.down
    change_column :order_line_items, :price, :float
    change_column :account_item_prices, :price, :float
    change_column :group_item_prices, :price, :float
    change_column :item_vendor_prices, :price, :float
    change_column :items, :price, :float
    change_column :items, :sale_price, :float
    change_column :items, :cost_price, :float
    change_column :order_shipping_methods, :amount, :float
    change_column :payments, :amount, :float
    change_column :shipping_methods, :rate, :float
    change_column :transactions, :amount, :float
  end
  
end
