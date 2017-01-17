class EquipmentAlert < ActiveRecord::Base
  
  belongs_to :equipment
  belongs_to :order_line_item
  before_save :associate_equipement
  after_save :set_start_alert_to_inactive
  
  
  def associate_equipement
    self.equipment_id = Equipment.find_by(:serial => equipment_serial).id unless Equipment.find_by(:serial => equipment_serial).nil?
  end
  
  def set_start_alert_to_inactive
    if self.alert_type == "end"
      a = EquipmentAlert.find_by(:alert_identification => self.alert_identification, :alert_type => "start")
      if a
        a.update_attributes(:active => false)
      end
    end
  end
  
end