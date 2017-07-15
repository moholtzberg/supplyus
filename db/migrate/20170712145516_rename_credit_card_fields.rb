class RenameCreditCardFields < ActiveRecord::Migration
  def change
    rename_column :credit_cards, :account_id, :account_payment_service_id
    rename_column :credit_cards, :stripe_card_id, :service_card_id
    remove_column :credit_cards, :stripe_customer_id, :integer
  end
end
