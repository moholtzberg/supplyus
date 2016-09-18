class ItemProperty < ActiveRecord::Base
  
  belongs_to :item, :touch => true
  
  validates_uniqueness_of :key, scope: :item_id
  
end