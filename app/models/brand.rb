class Brand < ActiveRecord::Base
  
  has_many :items
  
  default_scope { order(:name)}
  
  scope :active, -> () { where(:active => true) }
  
  # validates_uniqueness_of :name

  def self.lookup(word)
    where("lower(name) like ?", "%#{word.downcase}%")
  end
  
end