class Meter < ActiveRecord::Base
  include ApplicationHelper
  
  belongs_to :equipment
  has_many :meter_readings
  
  scope :by_account, -> (account_id) { where(account_id: account_id) }
  scope :by_equipment, -> (equipment_id) { where(equipment_id: equipment_id) }
  scope :by_meter_type, -> (type) { where(meter_type: type) }
  
  def last_valid_meter
    meter_readings.is_valid.by_display_desc.last.display.to_f
  end
  
end