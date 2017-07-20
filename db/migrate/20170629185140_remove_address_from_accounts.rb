class RemoveAddressFromAccounts < ActiveRecord::Migration
  def change
    remove_column :accounts, :ship_to_address_1
    remove_column :accounts, :ship_to_address_2
    remove_column :accounts, :ship_to_city
    remove_column :accounts, :ship_to_state
    remove_column :accounts, :ship_to_zip
    remove_column :accounts, :ship_to_phone
    remove_column :accounts, :ship_to_fax
    remove_column :accounts, :bill_to_address_1
    remove_column :accounts, :bill_to_address_2
    remove_column :accounts, :bill_to_city
    remove_column :accounts, :bill_to_state
    remove_column :accounts, :bill_to_zip
    remove_column :accounts, :bill_to_phone
    remove_column :accounts, :bill_to_fax
  end
end
