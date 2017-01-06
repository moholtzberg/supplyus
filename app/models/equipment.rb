class Equipment < ActiveRecord::Base
  include ApplicationHelper
  
  # before_save :make_record_number
  
  belongs_to :customer, :foreign_key => "account_id"
  belongs_to :machine_model, :foreign_key => "model_id"
  has_one :contact
  has_many :meters
  has_many :alerts, :class_name => "EquipmentAlert"
  
  
  validates :serial, :presence => true, :uniqueness => true
  validates :number, :presence => true, :uniqueness => true
  validates_associated :customer
  validates_associated :machine_model
  
  def self.lookup(term)
    includes(:customer, :machine_model => [:make]).where("lower(equipment.number) like (?) or lower(serial) like (?) or lower(accounts.name) like (?) or lower(models.number) like (?)", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%").references(:customer, :machine_model => [:make])
  end
  
  def customer_name
    customer.try(:name)
  end
  
  def customer_name=(name)
    self.customer = Customer.find_by(:name => name) if name.present?
  end
  
  def model_number
    machine_model.try(:number)
  end
  
  def model_number=(number)
    self.machine_model = MachineModel.find_by(:number => number) if number.present?
  end
  
end