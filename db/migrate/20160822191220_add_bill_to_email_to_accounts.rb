class AddBillToEmailToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :bill_to_email, :string
  end
end
