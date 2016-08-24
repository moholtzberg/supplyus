class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.belongs_to :payment
      t.string :transaction_type
      t.float :amount
      t.string :authorization_code
    end
  end
end
