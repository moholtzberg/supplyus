class MeterReading < ActiveRecord::Base
  
  belongs_to :meter
  
  scope :by_meter, -> (meter_id) { where(:meter_id => meter_id) }
  scope :is_valid, -> { where(:is_valid => true) }
  scope :by_display_desc, -> { order(:display) }
  
  validate :reading_not_less_then_prevoius
  
  def reading_not_less_then_prevoius
    unless self.display.to_f >= self.class.by_meter(meter_id).is_valid.by_display_desc.last.display.to_f
      errors.add(:display, "can't be less then last valid meter reading.")
    end
  end
  
  def last_reading
    self.class.by_meter(meter_id).is_valid.by_display_desc.last.display.to_f
  end
  
end