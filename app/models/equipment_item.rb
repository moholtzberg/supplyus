class EquipmentItem < ActiveRecord::Base
  
  belongs_to :machine_model
  belongs_to :item
  
end