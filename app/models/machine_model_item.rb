class MachineModelItem < ActiveRecord::Base
  
  belongs_to :machine_model
  belongs_to :item
  
  def machine_model_number
    machine_model.try(:name)
  end
  
  def machine_model_number=(number)
    self.machine_model = MachineModel.find_by(:number => number) if number.present?
  end
  
  def item_number
    item.try(:name)
  end
  
  def item_number=(number)
    self.item = Item.find_by(:number => number) if number.present?
  end
  
end