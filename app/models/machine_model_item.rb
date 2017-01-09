class MachineModelItem < ActiveRecord::Base
  
  belongs_to :machine_model
  belongs_to :item
  
end