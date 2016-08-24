class TaxRate < ActiveRecord::Base
  
  include ApplicationHelper
  
  def self.lookup(word)
    where("lower(region_name) like ? OR lower(region_code) like ? OR lower(state_code) like ? OR lower(zip_code) like ?", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%")
  end
  
  def name
    "#{region_name}_#{zip_code}"
  end
  
end