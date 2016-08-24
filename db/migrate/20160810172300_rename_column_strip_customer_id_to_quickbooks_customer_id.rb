class RenameColumnStripCustomerIdToQuickbooksCustomerId < ActiveRecord::Migration
  def change
    rename_column :accounts, :stripe_customer_id, :quickbooks_id
  end
end