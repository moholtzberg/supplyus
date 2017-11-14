class CreateAccountPaymentService < ActiveRecord::Migration
  def change
    create_table :account_payment_services do |t|
      t.string :name
      t.string :service_id
      t.integer :account_id
    end
  end
end
