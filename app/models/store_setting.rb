class StoreSetting
  
  def self.store_name
    Rails.cache.fetch("#{self.class.to_s.downcase}_store_name") {
      if Setting.find_by(:key => "store_name") == nil
        Setting.create(:key => "store_name", :value => "Site Name").value
      else
        Setting.find_by(:key => "store_name").value
      end 
    }
  end
  
  def self.store_phone_number
    # Rails.cache.fetch("#{self.class.to_s.downcase}_store_phone_number") {
      if Setting.find_by(:key => "store_phone_number") == nil
        Setting.create(:key => "store_phone_number", :value => "(888) 888-8888").value
      else
        Setting.find_by(:key => "store_phone_number").value
      end 
    # }
  end
  
  def self.store_address
    Rails.cache.fetch("#{self.class.to_s.downcase}_store_address") {
      if Setting.find_by(:key => "store_address") == nil
        Setting.create(:key => "store_address", :value => "123 Main Street").value
      else
        Setting.find_by(:key => "store_address").value
      end 
    }
  end
  
  def self.store_city
    Rails.cache.fetch("#{self.class.to_s.downcase}_store_city") {
      if Setting.find_by(:key => "store_city") == nil
        Setting.create(:key => "store_city", :value => "Anywhere").value
      else
        Setting.find_by(:key => "store_city").value
      end 
    }
  end
  
  def self.store_state
    Rails.cache.fetch("#{self.class.to_s.downcase}_store_state") {
      if Setting.find_by(:key => "store_state") == nil
        Setting.create(:key => "store_state", :value => "ST").value
      else
        Setting.find_by(:key => "store_state").value
      end 
    }
  end
  
  def self.store_zip
    Rails.cache.fetch("#{self.class.to_s.downcase}_store_zip") {
      if Setting.find_by(:key => "store_zip") == nil
        Setting.create(:key => "store_zip", :value => "12345").value
      else
        Setting.find_by(:key => "store_zip").value
      end 
    }
  end
  
end