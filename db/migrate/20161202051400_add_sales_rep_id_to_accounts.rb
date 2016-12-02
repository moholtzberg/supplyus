class AddSalesRepIdToAccounts < ActiveRecord::Migration
  def change
     add_column :accounts, :sales_rep_id, :integer
  end
end