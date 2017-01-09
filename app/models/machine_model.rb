class MachineModel < ActiveRecord::Base
  
  self.table_name = "models"
  
  belongs_to :make
  has_many :items
  has_many :equipments, :foreign_key => "model_id"
  has_many :machine_model_items
  
  def make_name
    make.try(:name)
  end
  
  def self.lookup(term)
    includes(:make).where("lower(models.number) like (?) or lower(makes.name) like (?)", "%#{term.downcase}%", "%#{term.downcase}%").references(:make)
  end
  
end
