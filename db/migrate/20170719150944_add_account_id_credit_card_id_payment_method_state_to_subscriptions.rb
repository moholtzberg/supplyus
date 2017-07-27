class AddAccountIdCreditCardIdPaymentMethodStateToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :account_id, :integer
    add_column :subscriptions, :credit_card_id, :integer
    add_column :subscriptions, :payment_method, :string
    add_column :subscriptions, :state, :string
  end
end
