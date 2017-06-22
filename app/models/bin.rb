class Bin < ActiveRecord::Base
  
  has_many :inventories
  belongs_to :warehouse
  
  validates :name, presence: true, uniqueness: { scope: :warehouse_id }
  validates :_type, presence: true, inclusion: { in: TYPES }

  TYPES = ['good', 'bad']

end