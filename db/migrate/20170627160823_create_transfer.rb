class CreateTransfer < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.integer :from_id
      t.integer :to_id
      t.integer :quantity
    end
  end
end
