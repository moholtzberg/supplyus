class Warehouse < ActiveRecord::Base

  TYPES = ['good', 'bad']
  
  has_many :bins
  
  validates :name, presence: true, uniqueness: true
  validates :_type, presence: true, inclusion: { in: TYPES }

  
end