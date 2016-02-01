class CreateEquipment < ActiveRecord::Migration
  def change
    create_table :equipment do |t|
      t.belongs_to :account
      t.belongs_to :contact
      t.belongs_to :payment_plan
      t.string :number
      t.string :serial
      t.string :make
      t.string :model
    end
  end
end