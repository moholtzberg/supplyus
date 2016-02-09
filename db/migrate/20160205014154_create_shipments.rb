class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.belongs_to :order
      t.string :number
      t.datetime :date
    end
  end
end
