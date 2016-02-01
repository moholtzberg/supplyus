class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.belongs_to :user
      t.string :account_type
      t.string :name
      t.string :stripe_customer_id
      t.string :number
      t.string :email
      t.string :ship_to_address_1
      t.string :ship_to_address_2
      t.string :ship_to_city
      t.string :ship_to_state
      t.string :ship_to_zip
      t.string :ship_to_phone
      t.string :ship_to_fax
      t.string :bill_to_address_1
      t.string :bill_to_address_2
      t.string :bill_to_city
      t.string :bill_to_state
      t.string :bill_to_zip
      t.string :bill_to_phone
      t.string :bill_to_fax
      # t.date :billing_start
      # t.integer :billing_day
      # t.integer :demo_period
      t.boolean :active
    end
  end
end
