class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :number
      t.integer :account_id
      t.timestamps null: false
    end
  end
end
