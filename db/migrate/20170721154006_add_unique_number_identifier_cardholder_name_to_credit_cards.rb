class AddUniqueNumberIdentifierCardholderNameToCreditCards < ActiveRecord::Migration
  def change
    add_column :credit_cards, :unique_number_identifier, :string
    add_column :credit_cards, :cardholder_name, :string
  end
end
