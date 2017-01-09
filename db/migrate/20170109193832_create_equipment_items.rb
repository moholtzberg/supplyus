class CreateEquipmentItems < ActiveRecord::Migration
  def change
    create_table :equipment_items do |t|
      t.belongs_to :equipment
      t.belongs_to :item
      t.string :supply_type
      t.string :supply_color
      t.integer :priority
      t.timestamps
    end
  end
end