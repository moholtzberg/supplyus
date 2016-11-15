class AddIsTaxableColumnToAccountsAndToOrders < ActiveRecord::Migration
  def change
    add_column :accounts, :is_taxable, :boolean
    add_column :orders, :is_taxable, :boolean
  end
end
