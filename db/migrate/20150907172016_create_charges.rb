class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.belongs_to :account
      t.belongs_to :payment_plan
      t.belongs_to :invoice
      t.float  :line_number
      t.float :amount
      t.float :quantity
      t.date :from_date
      t.date :to_date
      t.text :description
    end
  end
end
