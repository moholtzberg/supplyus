class AddCreditTermsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :credit_limit, :float, :default => 0.0
    add_column :accounts, :credit_terms, :integer
    add_column :accounts, :credit_hold, :boolean, :default => true
  end
end
