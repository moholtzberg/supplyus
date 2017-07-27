class AddCardTypeToCreditCard < ActiveRecord::Migration
  def change
    add_column :credit_cards, :card_type, :string
  end
end
