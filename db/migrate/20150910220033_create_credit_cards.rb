class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.belongs_to :account
      t.string :stripe_customer_id
      t.string :stripe_card_id
      t.string :expiration
    end
  end
end
