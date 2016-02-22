class Brand < ActiveRecord::Base
  
  has_many :items
  
  default_scope { order(:name)}
  
  scope :active, -> () { where(:active => true) }
  
  # validates_uniqueness_of :name
  
end