class Warehouse < ActiveRecord::Base

  TYPES = ['good', 'bad']
  
  has_many :bins
  
  validates :name, presence: true, uniqueness: true
  validates :_type, presence: true, inclusion: { in: TYPES }

  def self.lookup(word)
    includes(:bins).where("lower(warehouses.name) like ? or lower(bins.name) like ?", "%#{word.downcase}%", "%#{word.downcase}%").references(:bins)
  end
  
end