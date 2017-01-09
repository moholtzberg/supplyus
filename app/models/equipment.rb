class Equipment < ActiveRecord::Base
  include ApplicationHelper
  
  # before_save :make_record_number
  
  belongs_to :customer, :foreign_key => "account_id"
  belongs_to :machine_model, :foreign_key => "model_id"
  has_one :contact
  has_many :meters
  has_many :alerts, :class_name => "EquipmentAlert"
  has_many :machine_model_items, :class_name => "MachineModelItem", :through => :machine_model
  has_many :equipment_items
  
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
  
  def find_supply(type, color)
    supply = find_supply_for_equipment(type, color)
    if supply.nil?
      supply = find_supply_for_machine_model(type, color)
    end
    supply
  end
  
  def find_supply_for_equipment(type, color)
    es = equipment_items.where(:supply_type => type, :supply_color => color).order(:priority).first
    es unless es.nil?
  end
  
  def find_supply_for_machine_model(type, color)
    es = machine_model_items.where(:supply_type => type, :supply_color => color).order(:priority).first
    es unless es.nil?
  end
end