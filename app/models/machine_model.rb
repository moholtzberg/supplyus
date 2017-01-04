class MachineModel < ActiveRecord::Base
  
  self.table_name = "models"
  
  belongs_to :make
  has_many :items
  has_many :equipments, :foreign_key => "model_id"
  
  def make_name
    make.try(:name)
  end
  
end
