class CreateReciepts < ActiveRecord::Migration
  def change
    create_table :reciepts do |t|
      t.belongs_to :payment_plan
      t.date :from_date
      t.text :to_date
      t.float :amount
    end
  end
end
