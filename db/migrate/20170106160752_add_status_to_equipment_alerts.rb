class AddStatusToEquipmentAlerts < ActiveRecord::Migration
  def change
    add_column :equipment_alerts, :active, :boolean, null: false, default: true
  end
end
