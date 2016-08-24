class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.string :number
      t.integer :vendor_id
      t.integer :contact_id
      t.datetime :date
      t.datetime :due_date
      t.datetime :completed_at
      t.boolean :canceled
      t.boolean :locked
      t.boolean :drop_ship_order
      t.string :ship_to_account_name
      t.string :ship_to_address_1
      t.string :ship_to_address_2
      t.string :ship_to_attention
      t.string :ship_to_city
      t.string :ship_to_state
      t.string :ship_to_zip
      t.string :ship_to_phone
      t.string :ship_from_vendor_name
      t.string :ship_from_address_1
      t.string :ship_from_address_2
      t.string :ship_from_attention
      t.string :ship_from_city
      t.string :ship_from_state
      t.string :ship_from_zip
      t.string :ship_from_phone
      t.text :notes
      t.timestamps null: false
      t.timestamps null: false
    end
  end
end
