class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :number
      t.integer :account_id
      t.integer :contact_id
      t.integer :sales_rep_id
      t.datetime :date
      t.datetime :due_date
      t.datetime :completed_at
      t.boolean :canceled
      t.boolean :locked
      t.string :po_number
      t.string :ip_address
      t.string :ship_to_account_name
      t.string :ship_to_address_1
      t.string :ship_to_address_2
      t.string :ship_to_attention
      t.string :ship_to_city
      t.string :ship_to_state
      t.string :ship_to_zip
      t.string :ship_to_phone
      t.string :bill_to_account_name
      t.string :bill_to_address_1
      t.string :bill_to_address_2
      t.string :bill_to_attention
      t.string :bill_to_city
      t.string :bill_to_state
      t.string :bill_to_zip
      t.string :bill_to_phone
      t.text :notes
      t.timestamps null: false
    end
  end
end
