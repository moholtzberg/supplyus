class EquipmentAlert < ActiveRecord::Base
  
  belongs_to :equipment
  before_save :associate_equipement
  
  def associate_equipement
    self.equipment_id = Equipment.find_by(:serial => equipment_serial).id
  end
  
end