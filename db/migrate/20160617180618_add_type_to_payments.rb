class AddTypeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_type, :string, :default => "CreditCardPayment"
    add_column :payments, :first_name, :string
    add_column :payments, :last_name, :string
    add_column :payments, :last_four, :string
    add_column :payments, :card_type, :string
    add_column :payments, :success, :boolean, :default => false
    add_column :payments, :captured, :boolean, :default => false
    add_column :payments, :authorization_code, :string
    add_column :payments, :check_number, :string
  end
end
