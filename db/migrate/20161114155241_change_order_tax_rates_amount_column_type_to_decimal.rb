class ChangeOrderTaxRatesAmountColumnTypeToDecimal < ActiveRecord::Migration
  
  def self.up
    change_column :order_tax_rates, :amount, :decimal, :precision => 10, :scale => 2
  end
  
  def self.down
    change_column :order_tax_rates, :amount, :float
  end
  
end