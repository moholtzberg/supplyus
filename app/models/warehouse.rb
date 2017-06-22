class Warehouse < ActiveRecord::Base
  
  has_many :bins
  
  validates :name, presence: true, uniqueness: true
  validates :_type, presence: true, inclusion: { in: TYPES }

  TYPES = ['good', 'bad']
  
end