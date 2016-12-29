class FixColumnNameEquipmentMakeModel < ActiveRecord::Migration
  
  def self.up
    rename_column :equipment_alerts, :equipmnet_make_model, :equipment_make_model
  end

  def self.down
  end
  
end