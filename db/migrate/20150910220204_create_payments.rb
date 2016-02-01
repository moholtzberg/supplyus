class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      # t.belongs_to :invoice
      t.belongs_to :account
      t.belongs_to :payment_method
      t.belongs_to :credit_card
      t.float :amount
      t.string :stripe_charge_id
    end
  end
end
