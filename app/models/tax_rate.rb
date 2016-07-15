class TaxRate < ActiveRecord::Base
  
  def name
    "#{authority}_#{zip_code}"
  end
  
end