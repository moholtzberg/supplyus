class CreateEquipmentAlerts < ActiveRecord::Migration
  def change
    create_table :equipment_alerts do |t|
      t.belongs_to :equipment
      t.belongs_to :order_line_item
      t.string :alert_identification
      t.string :alert_type
      t.string :supply_type
      t.string :supply_color
      t.string :supply_part_number
      t.integer :supply_level
      t.string :equipment_serial
      t.string :equipment_asset_id
      t.string :equipmnet_make_model
      t.string :equipment_mac_address
      t.string :equipment_ip_address
      t.string :equipment_group_name
      t.string :equipment_location
      t.timestamps
    end
  end
end
